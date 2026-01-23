class RegistryConnector
  HTTP_SUCCESS = '200'.freeze
  HTTP_CREATED = '201'.freeze
  BASE_URL = URI(ENV['registry_api_url']).freeze
  BASE_KEY = "Basic #{ENV['registry_api_key']}".freeze

  attr_accessor :request

  def self.perform_request(request, url)
    response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
      http.request(request)
    end

    handle_response(response, request)
  rescue Timeout::Error, SocketError, Errno::ECONNREFUSED => e
    log_error(e, request, url, 'network_error')
    false
  rescue CommunicationError => e
    log_error(e, request, url, 'communication_error', e.response)
    false
  rescue StandardError => e
    log_error(e, request, url, 'unexpected_error')
    false
  end

  def self.request(url:, type:)
    request_by_type(type).new(
      url,
      'Content-Type': 'application/json',
      "Authorization": BASE_KEY
    )
  end

  def self.do_save(data)
    url = BASE_URL
    request = request(url: url, type: :post)
    request.body = { contact_request: data }.to_json
    perform_request(request, url)
  end

  def self.do_update(id:, data:)
    url = URI.join(BASE_URL, id.to_s)
    request = request(url: url, type: :put)
    request.body = { contact_request: data }.to_json
    perform_request(request, url)
  end

  def self.request_by_type(type)
    case type
    when :post
      Net::HTTP::Post
    else
      Net::HTTP::Put
    end
  end

  def self.logger
    Rails.logger
  end

  private_class_method

  def self.handle_response(response, request)
    if [HTTP_CREATED, HTTP_SUCCESS].include?(response.code.to_s)
      JSON.parse(response.body)
    else
      raise CommunicationError.new(request, response)
    end
  end

  def self.log_error(exception, request, url, event, response = nil)
    logger.error({
      timestamp: Time.current.utc.iso8601(3),
      level: 'error',
      message: "Registry API #{event.gsub('_', ' ')}",
      event: "registry.api.#{event}",
      service: 'rest-whois',
      environment: Rails.env,
      host: Socket.gethostname,
      pid: Process.pid,
      error: {
        type: exception.class.name,
        message: exception.message,
        stack: exception.backtrace&.first(5)&.join(' | ')
      },
      details: {
        url: url.to_s,
        request_method: request&.method,
        request_uri: request&.uri,
        response_body: response&.body
      },
      schema_version: '1.0.0',
      log_version: '1.0.0'
    }.to_json)
  end
end

class CommunicationError < StandardError
  attr_reader :request, :response

  def initialize(request = nil, response = nil)
    @request = request
    @response = response
    super("Communication failed with status #{response&.code}")
  end
end
