class CommunicationError < StandardError
  attr_reader :request, :response_code, :message

  def initialize(request, response_code)
    @request = request
    @response_code = response_code

    @message = <<~TEXT.squish
      Registry integration error. Request: #{request.uri}, body: #{request.body}
      Response: #{response_code}
    TEXT

    super(message)
  end
end
