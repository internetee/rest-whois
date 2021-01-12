class RegistryConnector
  HTTP_SUCCESS = '200'.freeze
  HTTP_CREATED = '201'.freeze
  BASE_URL = (URI(ENV['registry_api_url'] || 'http://registry:3000/api/v1/contact_requests/')).freeze
  BASE_KEY = "Basic #{ENV['registry_api_key']}".freeze

  attr_accessor :request

  def self.perform_request(request, url)
    @response = Net::HTTP.start(url.host, url.port,
                                use_ssl: url.scheme == 'https') do |http|
      http.request(request)
    end

    @body_as_string = @response.body
    @code_as_string = @response.code.to_s

    return true if [HTTP_CREATED, HTTP_SUCCESS].include? @code_as_string

    raise CommunicationError.new(request, @code_as_string)
  end

  def self.request(url:, type:)
    @request ||= request_by_type(type).new(
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
    url = URI.join(BASE_URL, "/contact_requests/#{id}")
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
