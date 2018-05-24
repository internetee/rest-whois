require 'test_helper'

class PrivatePersonWhoisRecordHTMLTest < ActionDispatch::IntegrationTest
  include CaptchaHelpers

  def setup
    @original_whitelist_ip = ENV['whitelist_ip']
    ENV['whitelist_ip'] = ''
    enable_captcha
  end

  def teardown
    ENV['whitelist_ip'] = @original_whitelist_ip
    disable_captcha
  end

  def test_html_returns_404_for_missing_domains
    visit('/v1/missing-domain.test')

    assert_equal(404, page.status_code)
    assert_text('Domain not found: missing-domain.test')
  end

  def test_returns_minimal_html
    visit("v1/discarded-domain.test")

    assert_text(
      <<-TEXT.squish
         Estonia .ee Top Level Domain WHOIS server
         Domain:
         name:       discarded-domain.test
         status:     deleteCandidate

         Estonia .ee Top Level Domain WHOIS server
         More information at http://internet.ee
    TEXT
    )
  end

  def test_html_has_disclaimer_text
    visit('/v1/privatedomain.test')

    assert_text(
      <<-TEXT.squish
    The information obtained through .ee WHOIS is subject to database protection
    according to the Estonian Copyright Act and international conventions. All
    rights are reserved to Estonian Internet Foundation. Search results may not
    be used for commercial,advertising, recompilation, repackaging,
    redistribution, reuse, obscuring or other similar activities. Downloading of
    information about domain names for the creation of your own database is not
    permitted. If any of the information from .ee WHOIS is transferred to a
    third party, it must be done in its entirety. This server must not be used
    as a backend for a search engine.
    TEXT
    )
  end

  def test_show_sensitive_data_of_legal_entity_when_captcha_is_solved
    with_captcha_test_keys do
      visit '/v1/company-domain.test'
      click_button 'View full whois info'
    end

    assert_text(
      <<-TEXT.squish
        Registrant:
        name:    test
        org id:  123
        country: EE
        email:   owner@company-domain.test
        changed: 2018-04-25 14:10:41 +03:00

        Administrative contact:
        name:       Admin Contact
        email:      admin-contact@company-domain.test
        changed:    2018-04-25 14:10:41 +03:00
  
        Technical contact:
        name:       Tech Contact
        email:      tech-contact@company-domain.test
        changed:    2018-04-25 14:10:41 +03:00
      TEXT
    )
    assert_no_button 'View full whois info'
  end

  def test_hide_sensitive_data_of_private_entity_when_captcha_is_solved
    with_captcha_test_keys do
      visit '/v1/privatedomain.test'
      click_button 'View full whois info'
    end

    assert_text(
      <<-TEXT.squish
        Registrant:
        name:    Private Person
        email:   Not Disclosed
        changed: Not Disclosed
  
        Administrative contact:
        name:       Not Disclosed
        email:      Not Disclosed
        changed:    Not Disclosed
  
        Technical contact:
        name:       Not Disclosed
        email:      Not Disclosed
        changed:    Not Disclosed
      TEXT
    )
    assert_no_button 'View full whois info'
  end

  def test_hide_sensitive_data_of_private_entity_when_captcha_is_unsolved
    visit '/v1/privatedomain.test'

    assert_text(
      <<-TEXT.squish
        Registrant:
        name:    Private Person
        email:   Not Disclosed
        changed: Not Disclosed
        
        Administrative contact:
        name:       Not Disclosed
        email:      Not Disclosed
        changed:    Not Disclosed
        
        Technical contact:
        name:       Not Disclosed
        email:      Not Disclosed
        changed:    Not Disclosed
    TEXT
    )
    assert_button 'View full whois info'
  end

  def test_hide_sensitive_data_of_legal_entity_when_captcha_is_unsolved
    visit '/v1/company-domain.test'

    assert_text(
      <<-TEXT.squish
        Registrant:
        name:    test
        org id:  123
        country: EE
        email:   Not Disclosed - Visit www.internet.ee for webbased WHOIS
        changed: 2018-04-25 14:10:41 +03:00

        Administrative contact:
        name:       Not Disclosed - Visit www.internet.ee for webbased WHOIS
        email:      Not Disclosed - Visit www.internet.ee for webbased WHOIS
        changed:    Not Disclosed - Visit www.internet.ee for webbased WHOIS
  
        Technical contact:
        name:       Not Disclosed - Visit www.internet.ee for webbased WHOIS
        email:      Not Disclosed - Visit www.internet.ee for webbased WHOIS
        changed:    Not Disclosed - Visit www.internet.ee for webbased WHOIS
    TEXT
    )
    assert_button 'View full whois info'
  end

  def test_show_sensitive_data_of_private_entity_when_ip_is_in_whitelist
    ENV['whitelist_ip'] = '127.0.0.1'

    visit '/v1/privatedomain.test'

    assert_text(
      <<-TEXT.squish
        Registrant:
        name:    test
        email:   owner@privatedomain.test
        changed: 2018-04-25 14:10:41 +03:00
  
        Administrative contact:
        name:       Admin Contact
        email:      admin-contact@privatedomain.test
        changed:    2018-04-25 14:10:41 +03:00
 
        Technical contact:
        name:       Tech Contact
        email:      tech-contact@privatedomain.test
        changed:    2018-04-25 14:10:41 +03:00
    TEXT
    )
    assert_no_button 'View full whois info'
  end

  def test_show_sensitive_data_of_legal_entity_when_ip_is_in_whitelist
    ENV['whitelist_ip'] = '127.0.0.1'

    visit '/v1/company-domain.test'

    assert_text(
      <<-TEXT.squish
        Registrant:
        name:    test
        org id:  123
        country: EE
        email:   owner@company-domain.test
        changed: 2018-04-25 14:10:41 +03:00

        Administrative contact:
        name:       Admin Contact
        email:      admin-contact@company-domain.test
        changed:    2018-04-25 14:10:41 +03:00
  
        Technical contact:
        name:       Tech Contact
        email:      tech-contact@company-domain.test
        changed:    2018-04-25 14:10:41 +03:00
    TEXT
    )
    assert_no_button 'View full whois info'
  end

  def test_hide_sensitive_data_of_private_entity_when_ip_is_not_in_whitelist
    ENV['whitelist_ip'] = '127.0.0.2'

    visit '/v1/privatedomain.test'

    assert_text(
      <<-TEXT.squish
        Registrant:
        name:    Private Person
        email:   Not Disclosed
        changed: Not Disclosed
        
        Administrative contact:
        name:       Not Disclosed
        email:      Not Disclosed
        changed:    Not Disclosed
       
        Technical contact:
        name:       Not Disclosed
        email:      Not Disclosed
        changed:    Not Disclosed
    TEXT
    )
    assert_button 'View full whois info'
  end

  def test_hide_sensitive_data_of_legal_entity_when_ip_is_not_in_whitelist
    ENV['whitelist_ip'] = '127.0.0.2'

    visit '/v1/company-domain.test'

    assert_text(
      <<-TEXT.squish
        Registrant:
        name:    test
        org id:  123
        country: EE
        email:   Not Disclosed - Visit www.internet.ee for webbased WHOIS
        changed: 2018-04-25 14:10:41 +03:00

        Administrative contact:
        name:       Not Disclosed - Visit www.internet.ee for webbased WHOIS
        email:      Not Disclosed - Visit www.internet.ee for webbased WHOIS
        changed:    Not Disclosed - Visit www.internet.ee for webbased WHOIS
  
        Technical contact:
        name:       Not Disclosed - Visit www.internet.ee for webbased WHOIS
        email:      Not Disclosed - Visit www.internet.ee for webbased WHOIS
        changed:    Not Disclosed - Visit www.internet.ee for webbased WHOIS
    TEXT
    )
    assert_button 'View full whois info'
  end

  def test_multiple_entries_in_ip_whitelist
    ENV['whitelist_ip'] = '127.0.0.1, 127.0.0.2'
    visit '/v1/company-domain.test'
    assert_no_text 'Not Disclosed'
  end
end
