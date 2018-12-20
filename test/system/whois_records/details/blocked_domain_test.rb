require 'application_system_test_case'

class WhoisRecordDetailsBlockedDomainTest < ApplicationSystemTestCase
  setup do
    @whois_record = whois_records(:privately_owned)
    @whois_record.update!(name: 'shop.test', json: { name: 'shop.test',
                                                     status: [Domain::STATUS_BLOCKED] })
  end

  def test_domain_details
    visit whois_record_url(name: @whois_record.name)

    within '.domain' do
      assert_text 'Name shop.test'
      assert_text 'Statuses Blocked'

      assert_no_text 'Registered'
      assert_no_text 'Changed'
      assert_no_text 'Expire'
      assert_no_text 'Outzone'
      assert_no_text 'Delete'
    end
  end

  def test_no_other_data_besides_basic_domain_details
    visit whois_record_url(name: @whois_record.name)

    assert_no_text 'Registrant'
    assert_no_text 'Administrative contacts'
    assert_no_text 'Technical contacts'
    assert_no_text 'Registrar'
    assert_no_text 'Nameservers'
    assert_no_text 'DNSSEC'
  end

  def test_no_captcha
    visit whois_record_url(name: @whois_record.name)
    assert_no_captcha
  end

  def test_no_captcha_when_ip_is_whitelisted
    whitelist_current_ip
    visit whois_record_url(name: @whois_record.name)
    assert_no_captcha
  end
end
