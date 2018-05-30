require 'test_helper'

class ContactRequestsLoggingTest < ActionDispatch::IntegrationTest
  def setup
    super

    @private_domain = whois_records(:privately_owned)
    @contact_request = contact_requests(:valid)
    @logger = Rails.logger
    Rails.logger = TestLogger
  end

  def teardown
    super
    Rails.logger = @logger
  end

  def test_messages_are_logged_on_confirmation_email
    visit(new_contact_request_path(params: { domain_name: 'privatedomain.test' }))
    fill_in('contact_request[email]', with: 'i-want-to-contact-you@domain.com')
    fill_in('contact_request[name]', with: 'Test User')
    click_link_or_button 'Get a link'

    assert(TestLogger.log.include?('Confirmation request email registered to i-want-to-contact-you@domain.com (IP: 127.0.0.1)'))
  end

  def test_messages_are_logged_on_contact_email
    visit(contact_request_path(@contact_request.secret))
    check(option: 'admin_contacts')
    body = begin
      "<p>Message text with <a href='example.com'>link</a>.</p>\n" \
      'There is a next line character before this one.'
    end
    fill_in('email_body', with: body)
    click_link_or_button 'Send'

    assert(TestLogger.log.include?('Email sent to privatedomain.test contacts from email@example.com (IP: 127.0.0.1)'))
  end
end
