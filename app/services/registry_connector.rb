class RegistryConnector
  HTTP_SUCCESS = '200'.freeze
  HTTP_CREATED = '201'.freeze
  BASE_URL = URI(ENV['registry_api_url']).freeze
  BASE_KEY = "Basic #{ENV['registry_api_key']}".freeze

  attr_accessor :request

  def self.perform_request(request, url)
    @response = Net::HTTP.start(url.host, url.port,
                                use_ssl: url.scheme == 'https') do |http|
      http.request(request)
    end

    @body_as_string = @response.body
    @code_as_string = @response.code.to_s

    return JSON.parse(@body_as_string) if [HTTP_CREATED, HTTP_SUCCESS].include? @code_as_string

    raise CommunicationError.new(request, @code_as_string)
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
  rescue CommunicationError
    false
  end

  def self.do_update(id:, data:)
    url = URI.join(BASE_URL, id.to_s)
    request = request(url: url, type: :put)
    request.body = { contact_request: data }.to_json
    perform_request(request, url)
  rescue CommunicationError
    false
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
