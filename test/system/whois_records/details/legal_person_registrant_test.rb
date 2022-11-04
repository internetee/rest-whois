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
    @whois_record.update!(json: @whois_record.json.merge({ registrant: 'Acme', registrant_publishable: 'true' }))

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

  def test_registrant_phone_is_masked_when_not_disclosed
    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text "Phone Not Disclosed"
    end
  end

  def test_registrant_phone_is_masked_when_disclosed_and_unsolved_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant_disclosed_attributes: %w[phone] }))
    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text "Phone #{disclosable_mask}"
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
      assert_text 'Last update 2010-07-05T00:00:00+00:00'
    end
  end

  def test_registrant_phone_is_unmasked_when_disclosed_and_solved_captcha
    solve_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant_disclosed_attributes: %w[phone] }))
    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text "Phone +555.555"
    end
  end

  def test_admin_and_tech_contact_data_is_masked_when_captcha_is_unsolved
    visit whois_record_url(name: @whois_record.name)

    within '.admin-contacts' do
      assert_text "Name Not Disclosed"
      assert_text "Email Not Disclosed"
      assert_text "Phone Not Disclosed"
      assert_text "Last update Not Disclosed"
    end

    within '.tech-contacts' do
      assert_text "Name Not Disclosed"
      assert_text "Email Not Disclosed"
      assert_text "Phone Not Disclosed"
      assert_text "Last update Not Disclosed"
    end
  end

  def test_admin_and_tech_contact_data_is_unmasked_when_captcha_is_solved
    solve_captcha
    @whois_record.update!(json: @whois_record.json
                                  .merge({ admin_contacts: [{ name: 'John',
                                                              email: 'john@inbox.test',
                                                              phone: '+555.555',
                                                              changed: '2010-07-06T00:00:00+00:00',
                                                              contact_publishable: true,
                                                              disclosed_attributes: %w[name email phone changed]
                                                            }],
                                           tech_contacts: [{ name: 'William',
                                                             email: 'william@inbox.test',
                                                             phone: '+555.555',
                                                             changed: '2010-07-07T00:00:00+00:00',
                                                             contact_publishable: true,
                                                             disclosed_attributes: %w[name email phone changed]
                                                           }] }))

    visit whois_record_url(name: @whois_record.name)

    within '.admin-contacts' do
      assert_text 'Name John'
      assert_text 'Email john@inbox.test'
      assert_text '+555.555'
      assert_text '2010-07-06T00:00:00+00:00'
    end

    within '.tech-contacts' do
      assert_text 'Name William'
      assert_text 'Email william@inbox.test'
      assert_text '+555.555'
      assert_text '2010-07-07T00:00:00+00:00'
    end
  end

  def test_registrant_sensitive_data_is_masked_when_registrant_is_not_publishable
    @whois_record.update!(json: @whois_record.json.merge({ registrant_publishable: false }))
    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text "Name test"
      assert_text "Email #{disclosable_mask}"
      assert_text "Phone Not Disclosed"
      assert_text "Last update Not Disclosed - Visit www.internet.ee for web-based WHOIS"
    end
  end

  def test_registrant_sensitive_data_is_unmasked_when_registrant_is_publishable
    @whois_record.update!(json: @whois_record.json.merge({ registrant_publishable: true,
                                                           registrant_disclosed_attributes: %w[name email phone] }))
    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text 'Name test'
      assert_text 'Email owner@privatedomain.test'
      assert_text "Phone +555.555"
    end
  end

  private

  def disclosable_mask
    'Not Disclosed - Visit www.internet.ee for web-based WHOIS'
  end
end
