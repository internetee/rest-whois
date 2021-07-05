# Preview all emails at http://localhost:3000/rails/mailers/bounce_back_mailer
class BounceBackMailerPreview < ActionMailer::Preview
  def bounce_alert
    recipient = 'aaa@bbb.com'
    domain_name = 'some_domain_name.test'
    sender = 'Test Sender`s Name'
    BounceBackMailer.bounce_alert(recipient, domain_name, sender)
  end
end
