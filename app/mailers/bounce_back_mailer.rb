class BounceBackMailer < ApplicationMailer
  default from: ENV['mailer_from_address']

  def bounce_alert(recipient, domain_name, sender)
    @domain = domain_name
    @sender = sender
    mail(to: recipient, subject: t('bounce_back_mailer.bounce_alert.subject', domain: @domain))
  end
end
