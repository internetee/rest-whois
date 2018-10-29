class ContactRequestMailer < ApplicationMailer
  CHARACTER_LIMIT = (Figaro.env.mailer_character_limit || 2000).to_i
  default from: Figaro.env.mailer_from_address

  def confirmation_email(contact_request)
    @contact_request = contact_request
    recipients = contact_request.email
    @domain = contact_request.whois_record.name
    @locale = I18n.locale

    logger.warn("Confirmation email sent to #{recipients}.")

    mail(to: recipients, subject: t('contact_request_mailer.confirmation_email.subject'))
  end

  def contact_email(contact_request:, recipients:, mail_body:)
    @contact_request = contact_request
    @unsafe_body = mail_body
    @domain = contact_request.whois_record.name

    logger.warn("Contact email sent to #{recipients} from #{@contact_request.email}.")

    mail(to: recipients, reply_to: @contact_request.email)
  end
end
