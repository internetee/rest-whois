require 'application_system_test_case'

class WhoisRecordDetailsBaseTest < ApplicationSystemTestCase
  setup do
    @whois_record = whois_records(:privately_owned)

    @original_whitelist_ip = ENV['whitelist_ip']
    ENV['whitelist_ip'] = ''
  end

  teardown do
    ENV['whitelist_ip'] = @original_whitelist_ip
  end

  def test_disclaimer
    @whois_record.update!(disclaimer: 'some disclaimer')
    visit whois_record_url(name: @whois_record.name)
    assert_text 'some disclaimer'
  end

  def test_domain_details
    @whois_record.update!(json: @whois_record.json.merge({ name: 'shop.test',
                                                           status: %w[active],
                                                           registered: '2010-07-05T00:00:00+00:00',
                                                           changed: '2010-07-06T00:00:00+00:00',
                                                           expire: '2010-07-07T00:00:00+00:00',
                                                           outzone: '2010-07-08T00:00:00+00:00',
                                                           delete: '2010-07-09T00:00:00+00:00' }))

    visit whois_record_url(name: @whois_record.name)

    within '.domain' do
      assert_text 'Name shop.test'
      assert_text 'Statuses active'
      assert_text 'Registered 2010-07-05 00:00:00 +00:00'
      assert_text 'Changed 2010-07-06 00:00:00 +00:00'
      assert_text 'Expire 2010-07-07'
      assert_text 'Outzone 2010-07-08'
      assert_text 'Delete 2010-07-09'
    end
  end

  def test_registrant_details
    whitelist_current_ip
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrant: 'John',
                                           registrant_kind: 'priv',
                                           email: 'john@inbox.test',
                                           registrant_changed: '2010-07-05T00:00:00+00:00' }))

    visit whois_record_url(name: @whois_record.name)

    within '.registrant' do
      assert_text 'Name John'
      assert_text 'Email john@inbox.test'
      assert_text '+555.555'
      assert_text 'Last update Not Disclosed - Visit www.internet.ee for web-based WHOIS'
    end
  end

  def test_admin_contacts_details
    whitelist_current_ip
    @whois_record.update!(json: @whois_record.json
                                  .merge({ admin_contacts: [{ name: 'John',
                                                              email: 'john@inbox.test',
                                                              changed: '2010-07-05T00:00:00+00:00',
                                                            }] }))

    visit whois_record_url(name: @whois_record.name)

    within '.admin-contacts' do
      assert_text 'Name John'
      assert_text 'Email john@inbox.test'
      assert_text 'Not Disclosed - Visit www.internet.ee for web-based WHOIS'
    end
  end

  def test_tech_contacts_details
    whitelist_current_ip
    @whois_record.update!(json: @whois_record.json
                                  .merge({ tech_contacts: [{ name: 'John',
                                                             email: 'john@inbox.test',
                                                             changed: '2010-07-05T00:00:00+00:00',
                                                           }] }))

    visit whois_record_url(name: @whois_record.name)

    within '.tech-contacts' do
      assert_text 'Name John'
      assert_text 'Email john@inbox.test'
      assert_text 'Not Disclosed - Visit www.internet.ee for web-based WHOIS'
    end
  end

  def test_registrar_details
    @whois_record.update!(json: @whois_record.json
                                  .merge({ registrar: 'Bestnames',
                                           registrar_website: 'http://bestnames.test',
                                           registrar_phone: '1234',
                                           registrar_changed: '2010-07-05T00:00:00+00:00' }))

    visit whois_record_url(name: @whois_record.name)

    within '.registrar' do
      assert_text 'Name Bestnames'
      assert_text 'Website http://bestnames.test'
      assert_text 'Phone 1234'
      assert_text 'Last update 2010-07-05 00:00:00 +00:00'
    end
  end

  def test_nameservers
    @whois_record.update!(json: @whois_record.json
                                  .merge({ nameservers: %w[ns1.bestnames.test
                                                                      ns2.bestnames.test],
                                           nameservers_changed: '2010-07-05T00:00:00+00:00',
                                         }))

    visit whois_record_url(name: @whois_record.name)

    within '.nameservers' do
      assert_text 'nserver: ns1.bestnames.test'
      assert_text 'nserver: ns2.bestnames.test'
      assert_text 'Last update 2010-07-05 00:00:00 +00:00'
    end
  end

  def test_dnssec_keys
    @whois_record.update!(json: @whois_record.json
                                  .merge({ dnssec_keys: %w[one two],
                                           dnssec_changed: '2010-07-05T00:00:00+00:00',
                                         }))

    visit whois_record_url(name: @whois_record.name)

    within '.dnssec_keys' do
      assert_text 'dnskey: one'
      assert_text 'dnskey: two'
      assert_text 'Last update 2010-07-05 00:00:00 +00:00'
    end
  end

  def test_no_captcha_when_ip_is_whitelisted
    whitelist_current_ip
    visit whois_record_url(name: @whois_record.name)
    assert_no_captcha
  end

  def test_no_captcha_when_solved
    solve_captcha
    visit whois_record_url(name: @whois_record.name)
    assert_no_captcha
  end
end
