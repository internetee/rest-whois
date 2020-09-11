class BounceBackMailer < ApplicationMailer
  default from: ENV['mailer_from_address']

  def bounce_alert(json)
    json['bounce']['bouncedRecipients'].each do |recipient|
      mail_addr = recipient['emailAddress']
      mail(to: mail_addr, subject: t('bounce_back_mailer.bounce_alert.subject'))
    end
  end
end
