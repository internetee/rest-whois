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
          return unless contact_request
          return unless contact_request.registrant_bounced?(json['bounce']['bouncedRecipients'])

          BounceBackMailer.bounce_alert(
            contact_request.email, contact_request.whois_record['name']
          ).deliver_now
        end
      end
    end
  end
end