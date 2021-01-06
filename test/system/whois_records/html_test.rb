require 'application_system_test_case'

class PrivatePersonWhoisRecordHTMLTest < ApplicationSystemTestCase
  def setup
    super

    @original_whitelist_ip = ENV['whitelist_ip']
    ENV['whitelist_ip'] = ''
  end

  def teardown
    super

    ENV['whitelist_ip'] = @original_whitelist_ip
  end

  def test_missing_domain
    visit('/v1/whois/missing-domain.test')
    assert_text('Domain not found: missing-domain.test')
  end

  def test_invalid_domain
    visit('/v1/whois/1.test')
    assert_text 'Policy error: 1.test. Please study'
    assert_text 'Requirements for the registration of a Domain Name'
    assert_text 'https://www.internet.ee/domains/ee-domain-regulation#registration-of-domain-names'
  end

  def test_contact_form_link_is_visible_when_captcha_is_solved
    solve_captcha
    visit('/v1/whois/privatedomain.test')
    assert(has_link?('Contact owner'))
  end

  def test_contact_form_link_is_visible_when_captcha_is_unsolved
    visit('v1/whois/privatedomain.test')
    refute(has_link?('Contact owner'))
  end

  def test_multiple_entries_in_ip_whitelist
    ENV['whitelist_ip'] = '127.0.0.1, 127.0.0.2'
    visit '/v1/whois/company-domain.test'
    assert_no_text 'Not Disclosed'
  end
end
