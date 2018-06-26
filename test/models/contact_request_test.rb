require 'test_helper'

class ContactRequestTest < ActiveSupport::TestCase
  self.use_transactional_tests = true

  def setup
    super

    @whois_record = whois_records(:privately_owned)
    @contact_request = ContactRequest.new(
      whois_record: @whois_record,
      email: 'contact-me-here@email.com',
      name: 'Test User'
    )
  end

  def teardown
    super
  end

  def test_new_request_needs_required_fields
    contact_request = ContactRequest.new
    refute(contact_request.valid?)

    contact_request = ContactRequest.new(whois_record: @whois_record)
    refute(contact_request.valid?)

    contact_request = ContactRequest.new(whois_record: @whois_record,
                                         email: 'contact-me-here@email.com')
    refute(contact_request.valid?)

    contact_request = ContactRequest.new(whois_record: @whois_record,
                                         email: 'contact-me-here@email.com',
                                         name: 'Test User')
    assert(contact_request.valid?)
  end

  def test_new_request_has_default_status_new
    contact_request = ContactRequest.new
    assert_equal('new', contact_request.status)
  end

  def test_new_request_generates_random_124_character_secret_on_creation
    @contact_request.save
    assert_equal(128, @contact_request.secret.length)
  end

  def test_secret_cannot_be_changed
    @contact_request.save
    @contact_request.update!(secret: 'foo')
    @contact_request.reload

    refute_equal('foo', @contact_request.secret)
  end

  def test_valid_to_cannot_be_changed
    @contact_request.save
    new_date = Time.parse('2018-01-01 00:00 UTC')
    @contact_request.update!(valid_to: new_date)
    @contact_request.reload

    refute_equal(new_date, @contact_request.valid_to)
  end

  def test_can_be_confirmed_only_once
    @contact_request.save
    assert(@contact_request.confirm_email)
    refute(@contact_request.confirm_email)
  end

  def test_mark_as_sent
    @contact_request.save
    @contact_request.confirm_email

    assert(@contact_request.mark_as_sent)
  end

  def test_completed_or_expired_during_lifecycle
    @contact_request.save
    refute(@contact_request.completed_or_expired?)

    @contact_request.confirm_email
    refute(@contact_request.completed_or_expired?)

    @contact_request.mark_as_sent
    assert(@contact_request.completed_or_expired?)
  end

  def test_completed_or_expired_when_contact_request_is_old
    expired_request = contact_requests(:expired)
    assert(expired_request.completed_or_expired?)
  end

  def test_send_contact_email_makes_emails_unique
    whois_record_with_dupe_emails = whois_records(:with_duplicate_domain_contacts)
    not_unique_contact_request = ContactRequest.new(
      whois_record: whois_record_with_dupe_emails,
      email: 'contact-me-here@email.com',
      name: 'Test User'
    )
    not_unique_contact_request.save
    not_unique_contact_request.confirm_email

    body = 'some message text'
    recipients = %w[admin_contacts tech_contacts]
    not_unique_contact_request.send_contact_email(body: body, recipients: recipients)
    mail = ActionMailer::Base.deliveries.last
    assert_equal(['duplicate@domain.test'], mail.to)
  end

  def test_send_contact_email_updates_status_and_calls_mailer
    @contact_request.save
    @contact_request.confirm_email

    body = 'some message text'
    recipients = %w[admin_contacts]

    @contact_request.send_contact_email(body: body, recipients: recipients)
    assert(@contact_request.completed_or_expired?)
    assert_equal(ContactRequest::STATUS_SENT, @contact_request.status)

    mail = ActionMailer::Base.deliveries.last
    assert_equal(['no-reply@internet.ee'], mail.from)
    assert_equal(['owner@privatedomain.test', 'admin-contact@privatedomain.test'], mail.to)
    assert_equal(['contact-me-here@email.com'], mail.reply_to)
    assert_equal('Email to domain owner and/or contact', mail.subject)
    assert_match('some message text', mail.body.to_s)
  end

  def test_send_contact_email_only_to_tech_contact
    @contact_request.save
    @contact_request.confirm_email

    body = 'some message text'
    recipients = %w[tech_contacts]

    @contact_request.send_contact_email(body: body, recipients: recipients)
    assert(@contact_request.completed_or_expired?)
    assert_equal(ContactRequest::STATUS_SENT, @contact_request.status)

    mail = ActionMailer::Base.deliveries.last
    assert_equal(['tech-contact@privatedomain.test'], mail.to)
  end

  def test_send_contact_email_does_nothing_when_not_sendable
    @contact_request.save
    refute(@contact_request.send_contact_email)
  end

  def test_send_contact_email_does_nothing_when_recipients_are_empty
    @contact_request.save
    @contact_request.confirm_email

    assert_equal(ContactRequest::STATUS_CONFIRMED, @contact_request.status)
    refute(@contact_request.send_contact_email)
  end
end
