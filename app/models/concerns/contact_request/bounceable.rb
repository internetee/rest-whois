module Concerns
  module ContactRequest
    module Bounceable
      extend ActiveSupport::Concern

      def registrant_bounced?(bounced_recipients)
        registrant_email = whois_record.json['email']
        bounced_recipients.as_json.find { |r| break true if r['emailAddress'] == registrant_email }
      end

      class_methods do
        def send_bounce_alert(json)
          contact_request = find_by(message_id: json['mail']['messageId'])
          log_to_registry(json)
          return unless contact_request&.registrant_bounced?(json['bounce']['bouncedRecipients'])

          BounceBackMailer.bounce_alert(
            contact_request.email, contact_request.whois_record['name']
          ).deliver_now
        end

        def log_to_registry(json)
          return unless ENV['bounces_api_url']

          uri = URI.parse(ENV['bounces_api_url'])
          secret = ENV['bounces_api_shared_key']

          header = { 'Content-Type': 'application/json', 'Authorization': "Basic #{secret}" }
          body = { data: json }

          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.request_uri, header)
          request.body = body.to_json

          http.request(request)
        end
      end
    end
  end
end
