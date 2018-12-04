require 'application_system_test_case'

class WhoisRecordDetailsPrivatePersonRegistrantTest < ApplicationSystemTestCase
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

  def test_sensitive_data_is_masked_when_captcha_is_solved
    solve_captcha

    visit whois_record_url(name: @whois_record.name)
    assert_sensitive_data_is_masked
  end

  private

  def assert_sensitive_data_is_masked
    within '.registrant' do
      assert_text 'Name Private Person'
      assert_text "Email #{undisclosable_mask}"
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
