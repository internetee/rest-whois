class RegistryConnector
  HTTP_SUCCESS = '200'.freeze
  HTTP_CREATED = '201'.freeze
  BASE_URL = URI(ENV['registry_api_url'])
  BASE_KEY = "Basic #{ENV['registry_api_key']}"

  attr_accessor :request

  def self.perform_request(request, url)
    @response = Net::HTTP.start(url.host, url.port,
                                use_ssl: url.scheme == 'https') do |http|
      http.request(request(url))
    end

    @body_as_string = @response.body
    @code_as_string = @response.code.to_s

    return true if [HTTP_CREATED, HTTP_SUCCESS].include? @code_as_string

    raise CommunicationError.new(request, @code_as_string)
  end

  def self.request(url)
    @request ||= Net::HTTP::Post.new(
      url,
      'Content-Type': 'application/json',
      "Authorization": BASE_KEY
    )
  end

  def self.do_save(data)
    url = BASE_URL
    request(url).body = { contact_request: data }.to_json
    perform_request(request(url), url)
  end

  def self.do_update(data)
    url = URI.join(BASE_URL, "/contact_requests/#{data[:id]}")
    request.body = { contact_request: data }.to_json
    perform_request(request(url), url)
  end
end
