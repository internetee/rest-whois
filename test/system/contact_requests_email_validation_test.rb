# encoding: utf-8
require 'application_system_test_case'

class ContactRequestsEmailValidationTest < ApplicationSystemTestCase
  def setup
    super

    ActionMailer::Base.deliveries.clear
    @valid_contact_request = contact_requests(:valid)

    stub_request(:put, %r{http://(registry|localhost):3000/api/v1/contact_requests/\d+})
      .to_return(status: 200, body: @valid_contact_request.to_json)

    stub_request(:post, %r{http://(registry|localhost):3000/api/v1/contact_requests/})
      .to_return(status: 200, body: @valid_contact_request.to_json)
  end

  def test_rejects_invalid_email_without_at_sign
    submit_form(email: 'invalidemail.com')

    assert_text I18n.t('contact_requests.invalid_email')
    assert_no_email_sent
  end

  def test_rejects_invalid_email_with_at_and_no_domain
    submit_form(email: 'test@')

    assert_text I18n.t('contact_requests.invalid_email')
    assert_no_email_sent
  end

  def test_rejects_invalid_email_with_no_local_part
    submit_form(email: '@domain.com')

    assert_text I18n.t('contact_requests.invalid_email')
    assert_no_email_sent
  end

  def test_accepts_valid_email_address
    submit_form(email: 'valid@example.com')

    assert_text I18n.t('contact_requests.confirmation_completed.help')
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

  private

  def submit_form(email:)
    visit new_contact_request_path(params: { domain_name: 'privatedomain.test' })
    fill_in 'contact_request[email]', with: email
    fill_in 'contact_request[name]', with: 'Test User'
    click_button 'Get a link'
  end

  def assert_no_email_sent
    assert_equal 0, ActionMailer::Base.deliveries.count
  end
end
