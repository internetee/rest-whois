require 'test_helper'

class WhoisRecordHTMLTest < ActionDispatch::IntegrationTest
  def test_HTML_has_disclaimer_text
    visit('/v1/domain.test')

    assert_text(
      <<-TEXT.squish
    The information obtained through .ee WHOIS is subject to database protection
    according to the Estonian Copyright Act and international conventions. All
    rights are reserved to Estonian Internet Foundation. Search results may not
    be used for commercial, advertising, recompilation, repackaging,
    redistribution, reuse, obscuring or other similar activities. Downloading of
    information about domain names for the creation of your own database is not
    permitted. If any of the information from .ee WHOIS is transferred to a
    third party, it must be done in its entirety. This server must not be used
    as a backend for a search engine.
    TEXT
    )

    assert_text(
      <<-TEXT.squish
      Registrant:
      name:    test
      email:   test@test.com
      changed: 2018-04-25 14:10:39 +03:00
      TEXT
    )
  end

  def test_HTML_with_failed_captcha
    # Setup
    Recaptcha.configuration.skip_verify_env.delete("test")
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

    visit('/v1/domain.test')


    assert_text(
      <<-TEXT.squish
      Registrant:
      name:    test
      email:   Not Disclosed - Visit www.internet.ee for webbased WHOIS
      changed: 2018-04-25 14:10:39 +03:00
      TEXT
    )

    # Continue skipping recaptcha in other tests
    Recaptcha.configuration.skip_verify_env = ['test', 'cucumber']
  end
end
