require 'test_helper'

class ContactRequestMailerLoggingTest < ActionMailer::TestCase
  def setup
    super

    @contact_request = contact_requests(:valid)
    @logger = Rails.logger
    Rails.logger = TestLogger
  end

  def teardown
    super
    Rails.logger = @logger
  end

  def test_messages_are_logged_on_confirmation_email
    ContactRequestMailer.confirmation_email(@contact_request).deliver_now
    assert(TestLogger.log.include?('Confirmation email sent to email@example.com.'))
  end

  def test_messages_are_logged_on_contact_email
    ContactRequestMailer.contact_email(
      contact_request: @contact_request,
      recipients: ['admin@privatedomain.com', 'owner@private_domain.com'],
      mail_body: 'Some text'
    ).deliver_now

    assert(TestLogger.log.include?("Contact email sent to [\"admin@privatedomain.com\", " \
                                   "\"owner@private_domain.com\"] from email@example.com."))
  end
end
