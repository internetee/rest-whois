require 'test_helper'

class WhoisRecordPolicy2027HtmlTest < ActionDispatch::IntegrationTest
  setup do
    @original_whitelist_ip = ENV['whitelist_ip']
    ENV['whitelist_ip'] = ''
    stub_request(:get, /google.com\/recaptcha/).to_return(body: '{}')
    enable_captcha

    @original_active_from = DisclosurePolicy.active_from
    DisclosurePolicy.active_from = 1.minute.ago
  end

  teardown do
    ENV['whitelist_ip'] = @original_whitelist_ip
    DisclosurePolicy.active_from = @original_active_from
    disable_captcha
  end

  def test_public_level_masks_sensitive_data_and_shows_captcha
    get '/v1/policy-org.test'

    assert_response :ok
    assert_includes response.body, 'Not Disclosed - Visit www.internet.ee for web-based WHOIS'
    assert_includes response.body, 'Not Disclosed'
    refute_includes response.body, 'ACME OÜ'
    refute_includes response.body, 'owner@policy-org.test'
    refute_includes response.body, '12345678'

    # public fields are still rendered
    assert_includes response.body, '<dd>org</dd>'
    assert_includes response.body, 'nserver: ns1.policy-org.test 192.0.2.1 2001:db8::1'
    assert_includes response.body, 'nserver: ns2.policy-org.test 192.0.2.2'
    assert_includes response.body, 'registrar@test.test'
    assert_includes response.body, 'Street 1, Tallinn, Harjumaa, 10111'

    assert_includes response.body, 'Show full WHOIS info'
    refute_includes response.body, 'Contact owner'
    refute_equal 'private, no-store', response.headers['Cache-Control']
  end

  def test_detailed_level_reveals_org_data_and_hides_captcha
    solve_captcha

    get '/v1/policy-org.test'

    assert_response :ok
    assert_includes response.body, 'ACME OÜ'
    assert_includes response.body, 'owner@policy-org.test'
    assert_includes response.body, '12345678'
    assert_includes response.body, 'Tech Org'

    # private tech contact and admin contacts stay hidden
    refute_includes response.body, 'Tech Priv'
    refute_includes response.body, 'Admin Org'
    refute_includes response.body, '11223344'
    refute_includes response.body, '87654321'
    assert_includes response.body, 'Not Disclosed'

    refute_includes response.body, 'Show full WHOIS info'
    assert_equal 'private, no-store', response.headers['Cache-Control']
  end

  def test_privileged_level_reveals_everything
    ENV['whitelist_ip'] = '127.0.0.1'

    get '/v1/policy-org.test'

    assert_response :ok
    assert_includes response.body, 'ACME OÜ'
    assert_includes response.body, 'Tech Priv'
    assert_includes response.body, 'Admin Priv'
    assert_includes response.body, '11223344'
    assert_includes response.body, '87654321'
    refute_includes response.body, 'Not Disclosed'
    refute_includes response.body, 'Show full WHOIS info'
    assert_equal 'private, no-store', response.headers['Cache-Control']
  end

  def test_private_registrant_page_offers_contact_owner_link_at_detailed
    get '/v1/policy-priv.test'

    assert_includes response.body, '<dd>priv</dd>'
    refute_includes response.body, 'Peeter Pera'
    refute_includes response.body, 'Contact owner'

    solve_captcha
    get '/v1/policy-priv.test'

    refute_includes response.body, 'Peeter Pera'
    assert_includes response.body, 'Tech Org'
    assert_includes response.body, 'Contact owner'
  end

  def test_inactive_domain_shows_minimal_data_and_no_captcha
    get '/v1/discarded-domain.test'

    assert_response :ok
    assert_includes response.body, 'discarded-domain.test'
    assert_includes response.body, Domain::STATUS_DISCARDED
    refute_includes response.body, 'Show full WHOIS info'
    refute_includes response.body, 'Not Disclosed'
  end

  def test_html_dispatch_before_at_and_after_activation
    activation = Time.zone.parse('2027-01-18T00:00:00+02:00')
    DisclosurePolicy.active_from = activation

    [-1.second, 0.seconds, 1.second].each do |offset|
      travel_to activation + offset do
        get '/v1/policy-org.test'

        if offset.negative?
          assert_includes response.body, 'ACME OÜ'
          refute_includes response.body, 'registrar@test.test'
        else
          refute_includes response.body, 'ACME OÜ'
          assert_includes response.body, 'registrar@test.test'
        end
      end
    end
  end

  def test_privileged_private_registrant_page_discloses_data_and_contact_link
    ENV['whitelist_ip'] = '127.0.0.1'

    get '/v1/policy-priv.test'

    assert_includes response.body, 'Peeter Pera'
    assert_includes response.body, 'owner@policy-priv.test'
    assert_includes response.body, 'Admin Priv'
    assert_includes response.body, 'Contact owner'
    refute_includes response.body, 'Show full WHOIS info'
    assert_equal 'private, no-store', response.headers['Cache-Control']
  end
end
