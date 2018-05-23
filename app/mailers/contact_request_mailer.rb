class ContactRequestMailer < ApplicationMailer
  CHARACTER_LIMIT = (Figaro.env.mailer_character_limit || 2000).to_i
  default from: Figaro.env.mailer_from_address

  def confirmation_email(contact_request)
    @contact_request = contact_request
    recipients = contact_request.email
    @domain    = contact_request.whois_record.name
    mail(to: recipients,
         subject: I18n.t('contact_requests.confirmation_email_subject', domain: @domain))
  end

  def contact_email(contact_request:, recipients:, mail_body:)
    @contact_request = contact_request
    @unsafe_body = mail_body
    mail(to: recipients,
         subject: I18n.t('contact_requests.contact_request_email_subject', domain: @domain),
         reply_to: @contact_request.email)
  end
end
