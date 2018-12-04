require 'test_helper'

class PrivatePersonWhoisRecordHTMLTest < ActionDispatch::IntegrationTest
  include CaptchaHelpers

  def setup
    super

    @original_whitelist_ip = ENV['whitelist_ip']
    ENV['whitelist_ip'] = ''
    enable_captcha
  end

  def teardown
    super

    ENV['whitelist_ip'] = @original_whitelist_ip
    disable_captcha
  end

  def test_html_returns_404_for_missing_domains
    visit('/v1/missing-domain.test')

    assert_equal(404, page.status_code)
    assert_text('Domain not found: missing-domain.test')
  end

  def test_contact_form_link_is_visible_when_captcha_is_solved
    with_captcha_test_keys do
      visit('/v1/privatedomain.test')
      click_button 'Show full WHOIS info'
    end

    assert(has_link?('Contact owner'))
  end

  def test_contact_form_link_is_visible_when_captcha_is_unsolved
    visit("v1/privatedomain.test")
    refute(has_link?('Contact owner'))
  end

  def test_multiple_entries_in_ip_whitelist
    ENV['whitelist_ip'] = '127.0.0.1, 127.0.0.2'
    visit '/v1/company-domain.test'
    assert_no_text 'Not Disclosed'
  end
end
