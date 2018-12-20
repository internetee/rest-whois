require 'application_system_test_case'

class WhoisRecordDetailsLegalPersonRegistrantTest < ApplicationSystemTestCase
  setup do
    @whois_record = whois_records(:privately_owned)
    @whois_record.update!(json: @whois_record.json.merge({ registrant_kind: 'org' }))

    @original_whitelist_ip = ENV['whitelist_ip']
    ENV['whitelist_ip'] = ''
  end

  teardown do
    ENV['whitelist_ip'] = @original_whitelist_ip
  end

  def test_legal_person_specific_registrant_details_are_visible
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant_reg_no: '1234',
                                           registrant_ident_country_code: 'US' }))

    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text 'Reg. number 1234'
      assert_text 'Country US'
    end
  end

  def test_registrant_name_is_unmasked
    @whois_record.update!(json: @whois_record.json.merge({ registrant: 'Acme' }))

    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text 'Name Acme'
    end
  end

  def test_registrant_email_and_last_update_are_masked_when_captcha_is_unsolved
    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text "Email #{disclosable_mask}"
      assert_text "Last update #{disclosable_mask}"
    end
  end

  def test_registrant_email_and_last_update_are_unmasked_when_captcha_is_solved
    solve_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ email: 'john@inbox.test',
                                           registrant_changed: '2010-07-05T00:00:00+00:00' }))

    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text 'Email john@inbox.test'
      assert_text 'Last update 2010-07-05 00:00:00 +00:00'
    end
  end

  def test_admin_and_tech_contact_data_is_masked_when_captcha_is_unsolved
    visit whois_record_url(name: @whois_record.name)

    within '.admin-contacts' do
      assert_text "Name #{disclosable_mask}"
      assert_text "Email #{disclosable_mask}"
      assert_text "Last update #{disclosable_mask}"
    end

    within '.tech-contacts' do
      assert_text "Name #{disclosable_mask}"
      assert_text "Email #{disclosable_mask}"
      assert_text "Last update #{disclosable_mask}"
    end
  end

  def test_admin_and_tech_contact_data_is_unmasked_when_captcha_is_solved
    solve_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ admin_contacts: [{ name: 'John',
                                                              email: 'john@inbox.test',
                                                              changed: '2010-07-06T00:00:00+00:00',
                                                            }],
                                           tech_contacts: [{ name: 'William',
                                                             email: 'william@inbox.test',
                                                             changed: '2010-07-07T00:00:00+00:00',
                                                           }] }))

    visit whois_record_url(name: @whois_record.name)

    within '.admin-contacts' do
      assert_text 'Name John'
      assert_text 'Email john@inbox.test'
      assert_text 'Last update 2010-07-06 00:00:00 +00:00'
    end

    within '.tech-contacts' do
      assert_text 'Name William'
      assert_text 'Email william@inbox.test'
      assert_text 'Last update 2010-07-07 00:00:00 +00:00'
    end
  end

  private

  def disclosable_mask
    'Not Disclosed - Visit www.internet.ee for web-based WHOIS'
  end
end
