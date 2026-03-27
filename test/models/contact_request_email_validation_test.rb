require 'test_helper'

class ContactRequestEmailValidationTest < ActiveSupport::TestCase
  def setup
    super
    @whois_record = whois_records(:privately_owned)
  end

  def test_rejects_email_without_at_sign
    assert_invalid_email 'invalidemail.com'
  end

  def test_rejects_empty_email
    assert_invalid_email ''
  end

  def test_rejects_email_with_only_at_sign
    assert_invalid_email '@'
  end

  def test_rejects_email_with_at_and_no_domain
    assert_invalid_email 'test@'
  end

  def test_rejects_email_with_no_local_part
    assert_invalid_email '@domain.com'
  end

  def test_accepts_valid_email_addresses
    valid_emails = [
      'user@example.com',
      'test.user@domain.co.uk',
      'user+tag@example.org',
      'user123@test-domain.ee',
      'user_name@sub.domain.com'
    ]

    valid_emails.each do |email|
      contact_request = build_contact_request(email)
      assert contact_request.valid?, "Email #{email} should be valid"
    end
  end

  def test_rejects_email_without_dot_in_domain
    assert_invalid_email 'test@domain'
  end

  def test_rejects_email_with_single_character_tld
    assert_invalid_email 'test@domain.c'
  end

  private

  def build_contact_request(email)
    ContactRequest.new(
      whois_record: @whois_record,
      email: email,
      name: 'Test User'
    )
  end

  def assert_invalid_email(email)
    contact_request = build_contact_request(email)

    refute contact_request.valid?, "Email #{email.inspect} should be invalid"
    assert_includes(
      contact_request.errors[:email],
      I18n.t('contact_requests.invalid_email')
    )
  end
end
