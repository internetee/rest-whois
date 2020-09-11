class BounceBackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def bounce
    json = JSON.parse(request.raw_post)
    if json['SubscribeURL']
      verify_sns_handler(json['SubscribeURL'])
    else
      logger.info "AWS has sent us the following bounce notification(s): #{json}"
      BounceBackMailer.bounce_alert(json).deliver_now if json['bouncedRecipients']
    end

    head :ok
  end

  def verify_sns_handler(verify_url)
    uri = URI.parse(verify_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.get(uri.request_uri)
  end
end