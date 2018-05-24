# Preview all emails at http://localhost:3000/rails/mailers/contact_request_mailer
class ContactRequestMailerPreview < ActionMailer::Preview
  def confirmation_email
    contact_request = ContactRequest.last
    ContactRequestMailer.confirmation_email(contact_request)
  end

  def contact_request_email
    contact_request = ContactRequest.last
    recipients = ['admin@domain.test', 'owner@domain.test']
    body = "<p> By all means, this <a href='https://example.com'>link</a> will be escaped.</p><br><br>This should be rendered on the same line"
    ContactRequestMailer.contact_email(contact_request: contact_request, recipients: recipients, mail_body: body)
  end
end
