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
    if ApplicationMailer.ses_configured?
      ses_contact_email(
        contact_request: contact_request, recipients: recipients, mail_body: mail_body
      )

    else
      smtp_contact_email(
        contact_request: contact_request, recipients: recipients, mail_body: mail_body
      )
    end
  end

  def smtp_contact_email(contact_request:, recipients:, mail_body:)
    @contact_request = contact_request
    @unsafe_body = mail_body
    @domain = contact_request.whois_record.name

    logger.warn("Contact email sent to #{recipients} from #{@contact_request.email}.")

    mail(to: recipients, reply_to: @contact_request.email)
  end

  def ses_contact_email(contact_request:, recipients:, mail_body:)
    @contact_request = contact_request
    @unsafe_body = mail_body
    @domain = contact_request.whois_record.name
    begin
      resp = Aws::SES::Client.new.send_email(ses_request_body(recipients))
      contact_request.update_registry_message_id(resp[:message_id])
      logger.warn("Contact email sent to #{recipients} from #{@contact_request.email}.")
    rescue Aws::SES::Errors::ServiceError => e
      logger.warn("Email not sent. Error message: #{e}")
    end
  end

  # rubocop:disable Metrics/MethodLength
  def ses_request_body(recipients)
    {
      source: ENV['mailer_from_address'],
      destination: { to_addresses: recipients },
      message: {
        body: {
          text: {
            charset: 'UTF-8',
            data: render_to_string(template: 'contact_request_mailer/contact_email'),
          },
        },
        subject: { charset: 'UTF-8', data: t('contact_request_mailer.contact_email.subject') },
      },
    }
  end
  # rubocop:enable Metrics/MethodLength
end
