class BounceBackMailer < ApplicationMailer
  default from: ENV['mailer_from_address']

  def bounce_alert(domain, json)
    json['bounce']['bouncedRecipients'].each do |recipient|
      mail_addr = recipient['emailAddress']
      mail(to: mail_addr, subject: t('contact_request_mailer.confirmation_email.subject', domain: domain))
    end
  end
end
