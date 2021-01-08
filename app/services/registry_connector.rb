class RegistryConnector
  HTTP_SUCCESS = '200'.freeze
  HTTP_CREATED = '201'.freeze
  BASE_URL = URI(ENV['registry_api_url'])
  BASE_KEY = "Basic #{ENV['registry_api_key']}"

  attr_accessor :request

  def self.perform_request(request)
    @response = Net::HTTP.start(BASE_URL.host, BASE_URL.port,
                                use_ssl: BASE_URL.scheme == 'https') do |http|
      http.request(request)
    end

    @body_as_string = @response.body
    @code_as_string = @response.code.to_s

    return true if [HTTP_CREATED, HTTP_SUCCESS].include? @code_as_string

    raise CommunicationError.new(request, @code_as_string)
  end

  def self.request
    @request ||= Net::HTTP::Post.new(
      BASE_URL,
      'Content-Type': 'application/json',
      "Authorization": BASE_KEY
    )
  end

  def self.do_save(data)
    request.body = { contact_request: data }.to_json
    perform_request(request)
  end
end
