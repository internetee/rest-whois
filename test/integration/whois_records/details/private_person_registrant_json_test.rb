require 'test_helper'

class WhoisRecordDetailsPrivatePersonRegistrantJSONTest < ActionDispatch::IntegrationTest
  include CaptchaHelpers

  setup do
    @whois_record = whois_records(:privately_owned)
    @whois_record.update!(json: @whois_record.json.merge({ registrant_kind: 'priv' }))

    @original_whitelist_ip = ENV['whitelist_ip']
    ENV['whitelist_ip'] = ''

    enable_captcha
  end

  teardown do
    ENV['whitelist_ip'] = @original_whitelist_ip
  end

  def test_registrant_name_is_unmasked_when_disclosed
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant: 'John',
                                           registrant_disclosed_attributes: %w[name] }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal 'John', response.parsed_body['registrant']
  end

  def test_registrant_email_is_masked_when_disclosed_and_captcha_is_unsolved
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant_disclosed_attributes: %w[email] }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal disclosable_mask, response.parsed_body['email']
  end

  def test_registrant_email_is_unmasked_when_disclosed_and_captcha_is_solved
    solve_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ email: 'john@inbox.test',
                                           registrant_disclosed_attributes: %w[email] }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal 'john@inbox.test', response.parsed_body['email']
  end

  def test_registrant_phone_is_masked_when_disclosed_and_captcha_is_unsolved
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant_disclosed_attributes: %w[phone] }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal disclosable_mask, response.parsed_body['phone']
  end

  def test_registrant_phone_is_unmasked_when_disclosed_and_captcha_is_solved
    solve_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ phone: '1234',
                                           registrant_disclosed_attributes: %w[phone] }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal '1234', response.parsed_body['phone']
  end

  def test_registrant_sensitive_data_is_masked_when_not_publishable
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant_publishable: false }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal 'Private Person', response.parsed_body['registrant']
    assert_equal 'Not Disclosed', response.parsed_body['email']
    assert_equal 'Not Disclosed', response.parsed_body['phone']
  end

  def test_registrant_sensitive_data_is_unmasked_when_publishable
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant_publishable: true }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal 'test', response.parsed_body['registrant']
    assert_equal 'owner@privatedomain.test', response.parsed_body['email']
    assert_equal '+555.555', response.parsed_body['phone']
  end

  def test_admin_contact_name_is_unmasked_when_disclosed
    @whois_record.update!(json: @whois_record.json
                                  .merge({ admin_contacts: [{ name: 'John',
                                                              disclosed_attributes: %w[name] }] }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal 'John', response.parsed_body['admin_contacts'].first['name']
  end

  def test_admin_contact_email_is_masked_when_disclosed_and_captcha_is_unsolved
    @whois_record.update!(json: @whois_record.json
                                  .merge({ admin_contacts: [{ disclosed_attributes: %w[email] }] }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal disclosable_mask, response.parsed_body['admin_contacts'].first['email']
  end

  def test_admin_contact_email_is_unmasked_when_disclosed_and_captcha_is_solved
    solve_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ admin_contacts: [{ email: 'john@inbox.test',
                                                              disclosed_attributes: %w[email] }] }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal 'john@inbox.test', response.parsed_body['admin_contacts'].first['email']
  end

  def test_tech_contact_name_is_unmasked_when_disclosed
    @whois_record.update!(json: @whois_record.json
                                  .merge({ tech_contacts: [{ name: 'John',
                                                             disclosed_attributes: %w[name] }] }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal 'John', response.parsed_body['tech_contacts'].first['name']
  end

  def test_tech_contact_email_is_masked_when_disclosed_and_captcha_is_unsolved
    @whois_record.update!(json: @whois_record.json
                                  .merge({ tech_contacts: [{ disclosed_attributes: %w[email] }] }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal disclosable_mask, response.parsed_body['tech_contacts'].first['email']
  end

  def test_tech_contact_email_is_unmasked_when_disclosed_and_captcha_is_solved
    solve_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ tech_contacts: [{ email: 'john@inbox.test',
                                                             disclosed_attributes: %w[email] }] }))

    get whois_record_path(name: @whois_record.name), as: :json

    assert_equal 'john@inbox.test', response.parsed_body['tech_contacts'].first['email']
  end

  def test_domain_at_auction
    @whois_record.update!(name: 'auction.test', json: { name: 'auction.test',
                                                        status: [Domain::STATUS_AT_AUCTION],
                                                        disclaimer: 'test' })

    get whois_record_path(name: @whois_record.name), as: :json

    assert_response :ok
    assert_equal ({ 'name' => 'auction.test', 'status' => [Domain::STATUS_AT_AUCTION],
                    'disclaimer' => 'test' }), response.parsed_body
  end

  private

  def disclosable_mask
    'Not Disclosed - Visit www.internet.ee for web-based WHOIS'
  end
end
