class BounceBackMailer < ApplicationMailer
  default from: ENV['mailer_from_address']

  def bounce_alert(recipient, domain_name)
    @domain = domain_name
    mail(to: recipient, subject: t('bounce_back_mailer.bounce_alert.subject'))
  end
end
