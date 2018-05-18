require 'test_helper'

class ContactRequestMailerTest < ActionMailer::TestCase
  def setup
    @contact_request = contact_requests(:valid)
  end

  def test_confirmation_email
    email = ContactRequestMailer
            .confirmation_email(@contact_request)
            .deliver_now

    refute(ActionMailer::Base.deliveries.empty?)
    assert_equal(['no-reply@internet.ee'], email.from)
    assert_equal(['email@example.com'], email.to)
    assert_equal('Send an email to privatedomain.test domain owner', email.subject)
    assert_equal(read_fixture('confirmation_email.erb').join, email.body.to_s)
  end

  def test_contact_request_email
    body = begin
      "Hi!\n" \
      "\n" \
      "I have an amazing business opportunity. Please contact me at my_email@test.com.\n" \
      "\n" \
      "Best regards,\n" \
      "John Smith"
    end
    email = ContactRequestMailer
            .contact_request_email(@contact_request, ['admin@privatedomain.com', 'owner@private_domain.com'], body)
            .deliver_now

    refute(ActionMailer::Base.deliveries.empty?)
    assert_equal(['no-reply@internet.ee'], email.from)
    assert_equal(['admin@privatedomain.com', 'owner@private_domain.com'], email.to)
    assert_equal(['email@example.com'], email.reply_to)
    assert_equal('Email to domain owner and/or contact', email.subject)
    assert_equal(read_fixture('contact_request_email.erb').join, email.body.to_s)
  end

  def test_contact_request_email_strips_html_tags_from_body
    body = begin
      "<p>Hello <a href='https://malicious-link.com'>there</a></p>"
    end
    email = ContactRequestMailer
            .contact_request_email(@contact_request, ['admin@privatedomain.com', 'owner@private_domain.com'], body)
            .deliver_now

    refute(ActionMailer::Base.deliveries.empty?)
    assert_equal(['no-reply@internet.ee'], email.from)
    assert_equal(['admin@privatedomain.com', 'owner@private_domain.com'], email.to)
    assert_equal(['email@example.com'], email.reply_to)
    assert_equal('Email to domain owner and/or contact', email.subject)
    assert_equal(read_fixture('stripped_contact_request_email.erb').join, email.body.to_s)
  end
end
