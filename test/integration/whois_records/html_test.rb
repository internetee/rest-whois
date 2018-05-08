require 'test_helper'

class PrivatePersonWhoisRecordHTMLTest < ActionDispatch::IntegrationTest
  def test_HTML_returns_404_for_missing_domains
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

  def test_HTML_has_disclaimer_text
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

  def test_HTML_for_private_person_does_not_contain_personal_data
    visit('/v1/privatedomain.test')
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
  end

  def test_HTML_for_company_with_failed_captcha
    # Setup
    Recaptcha.configuration.skip_verify_env.delete("test")
    headers = page.driver.options[:headers]
    page.driver.options[:headers] = {'REMOTE_ADDR' => '6.2.3.4'}

    # Returning empty JSON object from recaptcha means failure.
    stub_request(
      :get,
      "https://www.google.com/recaptcha/api/siteverify?remoteip=6.2.3.4&response=&secret=add-your-own-private-key"
    ).with(
      headers: {
	      'Accept'=>'*/*',
	      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
	      'User-Agent'=>'Ruby'
      }).
      to_return(status: 200, body: "{}", headers: {})

    visit('/v1/company-domain.test')

    assert_text(
      <<-TEXT.squish
      Registrant:
      name:    test
      org id:  123
      country: EE
      email:   Not Disclosed - Visit www.internet.ee for webbased WHOIS
      changed: 2018-04-25 14:10:41 +03:00
      TEXT
    )

    assert_text(
      <<-TEXT.squish
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

    # Continue skipping recaptcha in other tests
    page.driver.options[:headers] = headers
    Recaptcha.configuration.skip_verify_env = ['test', 'cucumber']
  end

  def test_HTML_for_company_with_whitelist_IP
    visit('/v1/company-domain.test')

    assert_text(
      <<-TEXT.squish
      Registrant:
      name:    test
      org id:  123
      country: EE
      email:  owner@company-domain.test
      changed: 2018-04-25 14:10:41 +03:00
      TEXT
    )

    assert_text(
      <<-TEXT.squish
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
  end
end
