require 'test_helper'

class RegistryConnectorTest < ActiveSupport::TestCase
  def setup
    @url = URI('http://registry.test/api/v1/contact_requests/')
    @request = Net::HTTP::Post.new(@url)
    @request.body = { contact_request: { email: 'test@example.com' } }.to_json
    @logger = create_logger_spy
  end

  {
    Timeout::Error => 'network_error',
    SocketError => 'network_error',
    Errno::ECONNREFUSED => 'network_error'
  }.each do |error_class, event_type|
    test "logs #{event_type} on #{error_class}" do
      perform_with_http_error(error_class.new('Simulated error')) do |result|
        assert_not result
      end

      assert_logged_with_event(event_type)
    end
  end

  test "logs communication_error with response body" do
    response = Net::HTTPBadRequest.new('1.1', '400', 'Bad Request')
    response.instance_variable_set(:@read, true)
    response.body = 'Error message'

    http_mock = Minitest::Mock.new
    http_mock.expect(:request, response, [@request])

    RegistryConnector.stub(:logger, @logger) do
      Net::HTTP.stub(:start, ->(*_args, &block) { block.call(http_mock) }) do
        result = RegistryConnector.perform_request(@request, @url)
        assert_not result
      end
    end

    assert_logged_with_event('communication_error')
    log_data = parse_logged_data
    assert_equal 'Error message', log_data['details']['response_body']
  end

  test "logs unexpected_error" do
    perform_with_http_error(StandardError.new('Unexpected error')) do |result|
      assert_not result
    end

    assert_logged_with_event('unexpected_error')
  end

  test "logged data contains required fields" do
    perform_with_http_error(Timeout::Error.new('Connection timeout'))
    
    log_data = parse_logged_data

    assert log_data['timestamp']
    assert_equal 'error', log_data['level']
    assert_equal 'registry.api.network_error', log_data['event']
    assert_equal 'rest-whois', log_data['service']
    assert_equal Rails.env, log_data['environment']
    assert log_data['host']
    assert log_data['pid']
    assert log_data['error']
    assert_equal 'Timeout::Error', log_data['error']['type']
    assert log_data['error']['message']
    assert log_data['details']
    assert_equal @url.to_s, log_data['details']['url']
    assert_equal 'POST', log_data['details']['request_method']
    assert log_data['schema_version']
    assert log_data['log_version']
  end

  test "logged data contains truncated error stack trace" do
    error = Timeout::Error.new('Connection timeout')
    error.set_backtrace(['line1', 'line2', 'line3', 'line4', 'line5', 'line6'])

    perform_with_http_error(error)

    log_data = parse_logged_data
    stack_trace = log_data['error']['stack']

    assert stack_trace
    assert_match(/line1/, stack_trace)
    assert_match(/line5/, stack_trace)
    refute_match(/line6/, stack_trace) 
  end

  private

  def perform_with_http_error(error)
    RegistryConnector.stub(:logger, @logger) do
      Net::HTTP.stub(:start, ->(*_args, &block) { raise error }) do
        result = RegistryConnector.perform_request(@request, @url)
        yield result if block_given?
        result
      end
    end
  end

  def create_logger_spy
    logged_messages = []

    logger_spy = Object.new
    logger_spy.define_singleton_method(:error) do |message|
      logged_messages << message
    end
    logger_spy.define_singleton_method(:logged_messages) do
      logged_messages
    end

    logger_spy
  end

  def assert_logged_with_event(event_type)
    assert @logger.logged_messages.any?, "Expected logger.error to be called"

    log_data = parse_logged_data
    assert_equal "registry.api.#{event_type}", log_data['event']
    assert_match(/Registry API #{event_type.gsub('_', ' ')}/, log_data['message'])
  end

  def parse_logged_data
    JSON.parse(@logger.logged_messages.last)
  end
end
