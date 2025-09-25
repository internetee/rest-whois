class RegistryConnector
  HTTP_SUCCESS = '200'.freeze
  HTTP_CREATED = '201'.freeze
  BASE_URL = URI(ENV['registry_api_url']).freeze
  BASE_KEY = "Basic #{ENV['registry_api_key']}".freeze

  attr_accessor :request

  def self.perform_request(request, url)
    response = Net::HTTP.start(url.host, url.port,
                               use_ssl: url.scheme == 'https') do |http|
      http.request(request)
    end

    body_as_string = response.body
    code_as_string = response.code.to_s

    if [HTTP_CREATED, HTTP_SUCCESS].include?(code_as_string)
      JSON.parse(body_as_string)
    else
      raise CommunicationError.new(request, code_as_string)
    end
  rescue Timeout::Error, SocketError, Errno::ECONNREFUSED => e
    logger.error({
      timestamp: Time.current.utc.iso8601(3),
      level: 'error',
      message: 'Registry API network connection failed',
      event: 'registry.api.network_error',
      service: 'rest-whois',
      environment: Rails.env,
      host: Socket.gethostname,
      pid: Process.pid,
      error: {
        type: e.class.name,
        message: e.message
      },
      details: {
        url: url.to_s,
        request_method: request.method,
        request_uri: request.uri
      },
      schema_version: '1.0.0',
      log_version: '1.0.0'
    }.to_json)
    false
  rescue CommunicationError => e
    logger.error({
      timestamp: Time.current.utc.iso8601(3),
      level: 'error',
      message: 'Registry API communication error',
      event: 'registry.api.communication_error',
      service: 'rest-whois',
      environment: Rails.env,
      host: Socket.gethostname,
      pid: Process.pid,
      error: {
        type: e.class.name,
        message: e.message
      },
      details: {
        url: url.to_s,
        request_method: request.method,
        request_uri: request.uri,
        response_body: response&.body
      },
      schema_version: '1.0.0',
      log_version: '1.0.0'
    }.to_json)
    false
  rescue StandardError => e
    logger.error({
      timestamp: Time.current.utc.iso8601(3),
      level: 'error',
      message: 'Registry API unexpected error',
      event: 'registry.api.unexpected_error',
      service: 'rest-whois',
      environment: Rails.env,
      host: Socket.gethostname,
      pid: Process.pid,
      error: {
        type: e.class.name,
        message: e.message,
        stack: e.backtrace&.first(5)&.join(' | ')
      },
      details: {
        url: url.to_s,
        request_method: request.method,
        request_uri: request.uri
      },
      schema_version: '1.0.0',
      log_version: '1.0.0'
    }.to_json)
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
end
