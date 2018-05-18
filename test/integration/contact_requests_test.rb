require 'test_helper'

class ContactRequestsTest < ActionDispatch::IntegrationTest
  def setup
    super

    @private_domain = whois_records(:privately_owned)
  end

  def teardown
    super
  end

  def test_new_request_fails_if_there_is_no_domain_name_passed
    assert_raise ActiveRecord::RecordNotFound do
      visit('/contact_requests/new')
    end
  end

  def test_form_is_rendered_correctly
    visit('/contact_requests/new?domain=privatedomain.test')
    assert(find_field('contact_request[email]'))
    text = begin
    "You will receive an one time link to confirm your email, and then send a message to the owner or administrator " \
    "of the domain.\n" \
    "The link expires in 24 hours."
    end

    assert_text(text)
  end

  def test_create_a_email_confirmation_delivery
    visit('/contact_requests/new?domain=privatedomain.test')
    fill_in 'contact_request[email]', with: 'i-want-to-contact-you@domain.com'
    click_link_or_button('Submit')

    assert_text('Contact request created. Check your email for a link to the one-time contact form.')

    mail = ActionMailer::Base.deliveries.last
    assert_equal(['no-reply@internet.ee'], mail.from)
    assert_equal(['i-want-to-contact-you@domain.com'], mail.to)
    assert_equal('Send an email to privatedomain.test domain owner', mail.subject)

    friendly_mail_body = mail.body.to_s
    expected_heading = 'Confirm your email'
    expected_body = 'Click the link below to send an email to owner of privatedomain.test.'
    expected_link = 'example.com/contact_request'
    expected_disclaimer = 'This link expires in 24 hours'


    assert_match(expected_heading,    friendly_mail_body)
    assert_match(expected_body,       friendly_mail_body)
    assert_match(expected_link,       friendly_mail_body)
    assert_match(expected_disclaimer, friendly_mail_body)
  end
end
