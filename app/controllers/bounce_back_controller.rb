class BounceBackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def bounce
    json = JSON.parse(request.raw_post)
    puts json
    if json['SubscribeURL']
      verify_sns_handler(json['SubscribeURL'])
    else
      logger.info("AWS has sent us the following bounce notification(s): #{json}")
      ContactRequest.send_bounce_alert(json) if json['bounce']['bouncedRecipients']
    end

    head(:ok)
  end

  def verify_sns_handler(verify_url)
    uri = URI.parse(verify_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.get(uri.request_uri)
  end
end