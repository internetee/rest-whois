class RegistryConnector
  HTTP_SUCCESS = '200'.freeze
  HTTP_CREATED = '201'.freeze
  BASE_URL = URI(ENV['registry_api_url']).freeze
  BASE_KEY = "Basic #{ENV['registry_api_key']}".freeze

  OPEN_TIMEOUT = 5 # seconds
  READ_TIMEOUT = 10 # seconds

  # The registry did not answer at all. Without these the caller would get an exception instead of
  # a plain false, and the user would see a 500 page instead of "try again later".
  NETWORK_ERRORS = [Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, Errno::ECONNRESET,
                    Errno::EHOSTUNREACH, Errno::ETIMEDOUT, SocketError, IOError,
                    OpenSSL::SSL::SSLError, JSON::ParserError].freeze

  def self.perform_request(request, url)
    response = Net::HTTP.start(url.host, url.port,
                               use_ssl: url.scheme == 'https',
                               open_timeout: OPEN_TIMEOUT,
                               read_timeout: READ_TIMEOUT) do |http|
      http.request(request)
    end

    code = response.code.to_s
    Rails.logger.info("Registry integration: #{request.method} #{url} -> #{code}")
    return JSON.parse(response.body) if [HTTP_CREATED, HTTP_SUCCESS].include?(code)

    raise CommunicationError.new(request, code)
  end

  def self.request(url:, type:)
    request_by_type(type).new(
      url,
      'Content-Type': 'application/json',
      "Authorization": BASE_KEY
    )
  end

  def self.do_save(data)
    submit(url: BASE_URL, type: :post, data: data)
  end

  def self.do_update(id:, data:)
    submit(url: record_url(id), type: :put, data: data)
  end

  def self.submit(url:, type:, data:)
    request = request(url: url, type: type)
    request.body = { contact_request: data }.to_json
    perform_request(request, url)
  rescue CommunicationError => e
    log_failure(type, url, "response code #{e.response_code}")
    false
  rescue *NETWORK_ERRORS => e
    log_failure(type, url, "#{e.class}: #{e.message}")
    false
  end

  # Deliberately without the request body: it carries the name, the email address and the IP of
  # the person behind the contact request, and those have no business being in an application log.
  def self.log_failure(type, url, reason)
    Rails.logger.error("Registry integration error. Request: #{type.to_s.upcase} #{url}, #{reason}")
  end

  # URI.join drops the last path segment when the base has no trailing slash, which would turn
  # every update into a request to a non-existent endpoint. Build the path by hand instead, so a
  # missing slash in `registry_api_url` cannot break updates.
  def self.record_url(id)
    URI("#{BASE_URL.to_s.chomp('/')}/#{id}")
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
