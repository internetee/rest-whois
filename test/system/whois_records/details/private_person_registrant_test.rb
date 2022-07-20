require 'application_system_test_case'

class WhoisRecordDetailsPrivatePersonRegistrantTest < ApplicationSystemTestCase
  setup do
    @whois_record = whois_records(:privately_owned)
    @whois_record.update!(json: @whois_record.json.merge({ registrant_kind: 'priv' }))

    @original_whitelist_ip = ENV['whitelist_ip']
    ENV['whitelist_ip'] = ''
  end

  teardown do
    ENV['whitelist_ip'] = @original_whitelist_ip
  end

  def test_legal_person_specific_registrant_details_are_hidden
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant_reg_no: 'legal-person-reg-number',
                                           registrant_ident_country_code: 'legal-person-country' }))

    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_no_text 'legal-person-reg-number'
      assert_no_text 'legal-person-country'
    end
  end

  def test_sensitive_data_is_masked_when_captcha_is_unsolved
    visit whois_record_url(name: @whois_record.name)
    assert_sensitive_data_is_masked
  end

  def test_sensitive_data_is_masked_when_registrant_is_not_publishable
    @whois_record.update!(json: @whois_record.json.merge({ registrant_publishable: false }))
    visit whois_record_url(name: @whois_record.name)
    assert_sensitive_data_is_masked
  end

  def test_sensitive_data_is_masked_when_captcha_is_solved
    solve_captcha

    visit whois_record_url(name: @whois_record.name)
    assert_sensitive_data_is_masked
  end

  def test_registrant_name_is_unmasked_when_disclosed
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant: 'John',
                                           registrant_disclosed_attributes: %w[name] }))

    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text 'Name John'
    end
  end

  def test_registrant_email_is_masked_when_disclosed_and_captcha_is_unsolved
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant_disclosed_attributes: %w[email] }))

    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text "Email #{disclosable_mask}"
    end
  end

  def test_registrant_email_is_unmasked_when_disclosed_and_captcha_is_solved
    solve_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ email: 'john@inbox.test',
                                           registrant_disclosed_attributes: %w[email] }))

    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text 'Email john@inbox.test'
    end
  end

  def test_registrant_phone_is_masked_when_disclosed_and_captcha_is_unsolved
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant_disclosed_attributes: %w[phone] }))

    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text "Phone #{disclosable_mask}"
    end
  end

  def test_registrant_phone_is_unmasked_when_disclosed_and_captcha_is_solved
    solve_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ phone: '1234',
                                           registrant_disclosed_attributes: %w[phone] }))

    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text 'Phone 1234'
    end
  end

  def test_registrant_sensitive_data_is_unmasked_when_registrant_is_publishable
    @whois_record.update!(json: @whois_record.json.merge({ registrant_publishable: true }))
    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text 'Name test'
      assert_text 'Email owner@privatedomain.test'
      assert_text 'Phone +555.555'
    end
  end

  def test_admin_contact_name_is_unmasked_when_disclosed
    @whois_record.update!(json: @whois_record.json
                                  .merge({ admin_contacts: [{ name: 'John',
                                                              disclosed_attributes: %w[name] }] }))

    visit whois_record_url(name: @whois_record.name)

    within '.admin-contacts' do
      assert_text 'Name John'
    end
  end

  def test_admin_contact_email_is_masked_when_disclosed_and_captcha_is_unsolved
    @whois_record.update!(json: @whois_record.json
                                  .merge({ admin_contacts: [{ disclosed_attributes: %w[email] }] }))

    visit whois_record_url(name: @whois_record.name)

    within '.admin-contacts' do
      assert_text "Email #{disclosable_mask}"
    end
  end

  def test_admin_contact_email_is_unmasked_when_disclosed_and_captcha_is_solved
    solve_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ admin_contacts: [{ email: 'john@inbox.test',
                                                              disclosed_attributes: %w[email] }] }))

    visit whois_record_url(name: @whois_record.name)

    within '.admin-contacts' do
      assert_text 'Email john@inbox.test'
    end
  end

  def test_tech_contact_name_is_unmasked_when_disclosed
    @whois_record.update!(json: @whois_record.json
                                  .merge({ tech_contacts: [{ name: 'John',
                                                             disclosed_attributes: %w[name] }] }))

    visit whois_record_url(name: @whois_record.name)

    within '.tech-contacts' do
      assert_text 'Name John'
    end
  end

  def test_tech_contact_email_is_masked_when_disclosed_and_captcha_is_unsolved
    @whois_record.update!(json: @whois_record.json
                                  .merge({ tech_contacts: [{ disclosed_attributes: %w[email] }] }))

    visit whois_record_url(name: @whois_record.name)

    within '.tech-contacts' do
      assert_text "Email #{disclosable_mask}"
    end
  end

  def test_tech_contact_email_is_unmasked_when_disclosed_and_captcha_is_solved
    solve_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ tech_contacts: [{ email: 'john@inbox.test',
                                                             disclosed_attributes: %w[email] }] }))

    visit whois_record_url(name: @whois_record.name)

    within '.tech-contacts' do
      assert_text 'Email john@inbox.test'
    end
  end

  private

  def assert_sensitive_data_is_masked
    within '.registrant' do
      assert_text 'Name Private Person'
      assert_text "Email #{undisclosable_mask}"
      assert_text "Phone #{undisclosable_mask}"
      assert_text "Last update #{undisclosable_mask}"
      assert_no_text disclosable_mask
    end

    within '.admin-contacts' do
      assert_text "Name #{undisclosable_mask}"
      assert_text "Email #{undisclosable_mask}"
      assert_text "Last update #{undisclosable_mask}"
      assert_no_text disclosable_mask
    end

    within '.tech-contacts' do
      assert_text "Name #{undisclosable_mask}"
      assert_text "Email #{undisclosable_mask}"
      assert_text "Last update #{undisclosable_mask}"
      assert_no_text disclosable_mask
    end
  end

  private

  def disclosable_mask
    'Not Disclosed - Visit www.internet.ee for web-based WHOIS'
  end

  def undisclosable_mask
    'Not Disclosed'
  end
end
