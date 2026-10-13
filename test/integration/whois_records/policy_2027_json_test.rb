require 'test_helper'

class WhoisRecordPolicy2027JsonTest < ActionDispatch::IntegrationTest
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

  def test_public_level_masks_org_registrant_and_dates
    get '/v1/policy-org.test', params: { format: :json }
    json = response.parsed_body

    assert_equal 'policy-org.test', json['name']
    assert_equal 'org', json['registrant_type']
    assert_equal 'org', json['registrant_kind']

    # revealed at the detailed level
    assert_equal disclosable_mask, json['registrant']
    assert_equal disclosable_mask, json['email']
    assert_equal disclosable_mask, json['registrant_reg_no']
    assert_equal disclosable_mask, json['registrant_ident_country_code']
    assert_equal disclosable_mask, json['changed']
    assert_equal disclosable_mask, json['outzone']
    assert_equal disclosable_mask, json['delete']

    # org phone is neither volunteered nor business-registry matched
    assert_equal undisclosable_mask, json['phone']

    # privileged only
    assert_equal undisclosable_mask, json['registrant_changed']
    assert_equal undisclosable_mask, json['registrar_changed']
    assert_equal undisclosable_mask, json['nameservers_changed']
    assert_equal undisclosable_mask, json['dnssec_changed']

    assert_equal '2018-04-25T14:10:41+00:00', json['registered']
    assert_equal '2018-07-25', json['expire']
    refute_equal 'private, no-store', response.headers['Cache-Control']
  end

  def test_public_level_marks_org_tech_contact_but_not_admin_contact
    get '/v1/policy-org.test', params: { format: :json }
    json = response.parsed_body

    tech = json['tech_contacts']
    assert_equal disclosable_mask, tech[0]['name']
    assert_equal disclosable_mask, tech[0]['email']
    assert_equal disclosable_mask, tech[0]['phone']
    assert_equal undisclosable_mask, tech[0]['changed']
    refute tech[0].key?('reg_no')
    refute tech[0].key?('ident_country_code')
    refute tech[0].key?('kind')

    # contact without `kind` is not an org
    assert_equal undisclosable_mask, tech[1]['name']
    assert_equal undisclosable_mask, tech[1]['email']
    assert_equal undisclosable_mask, tech[1]['phone']

    # admin contacts are never revealed at the detailed level
    admin = json['admin_contacts']
    assert_equal undisclosable_mask, admin[0]['name']
    assert_equal undisclosable_mask, admin[0]['email']
    assert_equal undisclosable_mask, admin[1]['name']
  end

  def test_public_level_shows_registrar_and_nameserver_records
    get '/v1/policy-org.test', params: { format: :json }
    json = response.parsed_body

    assert_equal 'Test Registrar', json['registrar']
    assert_equal 'https://registrar.test', json['registrar_website']
    assert_equal '+372 600 0000', json['registrar_phone']
    assert_equal 'registrar@test.test', json['registrar_email']
    assert_equal 'Street 1, Tallinn, Harjumaa, 10111', json['registrar_address']

    assert_equal %w[ns1.policy-org.test ns2.policy-org.test], json['nameservers']
    assert_equal(
      [
        { 'hostname' => 'ns1.policy-org.test',
          'ipv4' => ['192.0.2.1'],
          'ipv6' => ['2001:db8::1'] },
        { 'hostname' => 'ns2.policy-org.test',
          'ipv4' => ['192.0.2.2'],
          'ipv6' => [] }
      ],
      json['nameserver_records']
    )
  end

  def test_detailed_level_reveals_org_registrant_and_org_tech_contacts
    solve_captcha

    get '/v1/policy-org.test', params: { format: :json }
    json = response.parsed_body

    assert_equal 'ACME OÜ', json['registrant']
    assert_equal 'owner@policy-org.test', json['email']
    assert_equal '12345678', json['registrant_reg_no']
    assert_equal 'EE', json['registrant_ident_country_code']
    assert_equal '2018-04-26T14:10:41+00:00', json['changed']
    assert_equal '2018-07-25', json['outzone']
    assert_equal '2018-07-25', json['delete']

    assert_equal 'Tech Org', json['tech_contacts'][0]['name']
    assert_equal 'tech-org@policy-org.test', json['tech_contacts'][0]['email']
    assert_equal '+372 500 0003', json['tech_contacts'][0]['phone']

    # org phone is neither volunteered nor business-registry matched
    assert_equal undisclosable_mask, json['phone']

    # still privileged only
    assert_equal undisclosable_mask, json['registrant_changed']
    assert_equal undisclosable_mask, json['registrar_changed']
    assert_equal undisclosable_mask, json['nameservers_changed']
    assert_equal undisclosable_mask, json['dnssec_changed']
    assert_equal undisclosable_mask, json['tech_contacts'][0]['changed']
    refute json['tech_contacts'][0].key?('reg_no')
    refute json['admin_contacts'][0].key?('reg_no')

    # private tech contact and admin contacts stay hidden
    assert_equal undisclosable_mask, json['tech_contacts'][1]['name']
    assert_equal undisclosable_mask, json['admin_contacts'][0]['name']

    assert_equal 'private, no-store', response.headers['Cache-Control']
  end

  def test_privileged_level_shows_everything_in_the_blob
    ENV['whitelist_ip'] = '127.0.0.1'

    get '/v1/policy-org.test', params: { format: :json }
    json = response.parsed_body

    assert_equal 'ACME OÜ', json['registrant']
    assert_equal 'owner@policy-org.test', json['email']
    assert_equal '+372 500 0000', json['phone']
    assert_equal '2018-04-25T14:10:39+00:00', json['registrant_changed']
    assert_equal '2018-04-25T14:10:30+00:00', json['registrar_changed']
    assert_equal '2018-04-25T14:10:30+00:00', json['nameservers_changed']

    assert_equal 'Tech Org', json['tech_contacts'][0]['name']
    assert_equal 'Tech Priv', json['tech_contacts'][1]['name']
    assert_equal 'tech-priv@policy-org.test', json['tech_contacts'][1]['email']
    assert_equal '2018-04-25T14:10:41+00:00', json['tech_contacts'][0]['changed']

    assert_equal 'Admin Org', json['admin_contacts'][0]['name']
    assert_equal 'Admin Priv', json['admin_contacts'][1]['name']
    assert_equal 'org', json['tech_contacts'][0]['kind']
    assert_equal '11223344', json['tech_contacts'][0]['reg_no']
    assert_equal 'EE', json['tech_contacts'][0]['ident_country_code']
    assert_equal '87654321', json['admin_contacts'][0]['reg_no']
    assert_equal 'EE', json['admin_contacts'][0]['ident_country_code']
    assert_equal 'priv', json['admin_contacts'][1]['kind']
    refute json['admin_contacts'][1].key?('reg_no')

    assert_equal 'private, no-store', response.headers['Cache-Control']
  end

  def test_system_disclosed_org_phone_is_revealed_only_at_detailed
    record = whois_records(:policy_org_owned)
    record.update!(json: record.json.merge(
      'registrant_system_disclosed_attributes' => %w[phone],
      'registrant_disclosed_attributes' => %w[phone]
    ))

    get '/v1/policy-org.test', params: { format: :json }
    assert_equal disclosable_mask, response.parsed_body['phone']

    solve_captcha
    get '/v1/policy-org.test', params: { format: :json }
    assert_equal '+372 500 0000', response.parsed_body['phone']
  end

  def test_system_disclosed_phone_does_not_count_as_volunteered
    record = whois_records(:policy_org_owned)
    record.update!(json: record.json.merge(
      'registrant_publishable' => true,
      'registrant_disclosed_attributes' => %w[phone],
      'registrant_system_disclosed_attributes' => %w[phone]
    ))

    get '/v1/policy-org.test', params: { format: :json }

    assert_equal disclosable_mask, response.parsed_body['phone']
  end

  # Old blobs lack registrant_system_disclosed_attributes and the
  # business-registry checker wrote 'phone' into disclosed_attributes too,
  # so consent cannot be proven: the phone stays hidden at every level.
  def test_old_blob_registrant_phone_fails_closed
    record = whois_records(:policy_org_owned)
    data = record.json.deep_dup
    data.delete('registrant_system_disclosed_attributes')
    data['registrant_publishable'] = true
    data['registrant_disclosed_attributes'] = %w[name email phone]
    record.update!(json: data)

    get '/v1/policy-org.test', params: { format: :json }
    json = response.parsed_body

    assert_equal 'ACME OÜ', json['registrant']
    assert_equal 'owner@policy-org.test', json['email']
    assert_equal undisclosable_mask, json['phone']

    solve_captcha
    get '/v1/policy-org.test', params: { format: :json }
    json = response.parsed_body

    assert_equal 'ACME OÜ', json['registrant']
    assert_equal 'owner@policy-org.test', json['email']
    assert_equal undisclosable_mask, json['phone']
  end

  def test_registrant_phone_volunteered_when_system_disclosed_key_present_and_empty
    record = whois_records(:policy_org_owned)
    record.update!(json: record.json.merge(
      'registrant_publishable' => true,
      'registrant_disclosed_attributes' => %w[phone],
      'registrant_system_disclosed_attributes' => []
    ))

    get '/v1/policy-org.test', params: { format: :json }

    assert_equal '+372 500 0000', response.parsed_body['phone']
  end

  def test_volunteered_attributes_are_visible_at_public_level
    record = whois_records(:policy_priv_owned)
    record.update!(json: record.json.merge(
      'registrant_publishable' => true,
      'registrant_disclosed_attributes' => %w[name email phone],
      'admin_contacts' => [{ 'name' => 'Voluntary Admin',
                            'email' => 'vol@policy-priv.test',
                            'phone' => '+372 500 0099',
                            'contact_publishable' => true,
                            'disclosed_attributes' => %w[name email] }]
    ))

    get '/v1/policy-priv.test', params: { format: :json }
    json = response.parsed_body

    assert_equal 'Peeter Pera', json['registrant']
    assert_equal 'owner@policy-priv.test', json['email']
    assert_equal '+372 500 0000', json['phone']
    assert_equal 'Voluntary Admin', json['admin_contacts'][0]['name']
    assert_equal 'vol@policy-priv.test', json['admin_contacts'][0]['email']
    # phone was not in the contact's disclosed_attributes
    assert_equal undisclosable_mask, json['admin_contacts'][0]['phone']
  end

  def test_publishable_alone_does_not_disclose_attributes
    record = whois_records(:policy_priv_owned)
    record.update!(json: record.json.merge(
      'registrant_publishable' => true,
      'registrant_disclosed_attributes' => []
    ))

    get '/v1/policy-priv.test', params: { format: :json }
    json = response.parsed_body

    assert_equal undisclosable_mask, json['registrant']
    assert_equal undisclosable_mask, json['email']
  end

  def test_private_registrant_stays_masked_at_public_and_detailed
    get '/v1/policy-priv.test', params: { format: :json }
    json = response.parsed_body

    assert_equal 'priv', json['registrant_type']
    assert_equal undisclosable_mask, json['registrant']
    assert_equal undisclosable_mask, json['email']
    assert_equal undisclosable_mask, json['phone']
    assert_equal undisclosable_mask, json['registrant_reg_no']
    assert_equal undisclosable_mask, json['registrant_ident_country_code']

    # an org tech contact is revealed at detailed regardless of the
    # registrant's type
    assert_equal disclosable_mask, json['tech_contacts'][0]['name']

    solve_captcha
    get '/v1/policy-priv.test', params: { format: :json }
    json = response.parsed_body

    assert_equal undisclosable_mask, json['registrant']
    assert_equal undisclosable_mask, json['email']
    assert_equal undisclosable_mask, json['phone']
    assert_equal 'Tech Org', json['tech_contacts'][0]['name']
  end

  def test_old_blob_without_new_keys
    get '/v1/privatedomain.test', params: { format: :json }
    json = response.parsed_body

    assert_equal 'priv', json['registrant_type']
    assert_equal undisclosable_mask, json['registrant']
    assert_equal undisclosable_mask, json['registrant_reg_no']
    assert_nil json['registrar_email']
    assert_nil json['registrar_address']
    assert_equal [
      { 'hostname' => 'ns1.privatedomain.test', 'ipv4' => [], 'ipv6' => [] },
      { 'hostname' => 'ns2.privatedomain.test', 'ipv4' => [], 'ipv6' => [] }
    ], json['nameserver_records']

    # contacts without `kind` are not orgs even at the detailed level
    solve_captcha
    get '/v1/privatedomain.test', params: { format: :json }
    json = response.parsed_body
    assert_equal undisclosable_mask, json['tech_contacts'][0]['name']
  end

  def test_inactive_domain_returns_minimal_json
    get '/v1/discarded-domain.test', params: { format: :json }
    json = response.parsed_body

    assert_equal 'discarded-domain.test', json['name']
    assert_equal [Domain::STATUS_DISCARDED], json['status']
    refute json.key?('registrant_type')
    refute json.key?('registrant')
    refute json.key?('admin_contacts')
  end

  def test_inactive_policy_uses_legacy_pipeline
    DisclosurePolicy.active_from = nil

    get '/v1/policy-org.test', params: { format: :json }
    json = response.parsed_body

    refute json.key?('registrant_type')
    # the legacy legal-person partial always shows the registrant name
    assert_equal 'ACME OÜ', json['registrant']
  end

  def test_future_activation_uses_legacy_pipeline
    DisclosurePolicy.active_from = 1.minute.from_now

    get '/v1/policy-org.test', params: { format: :json }
    json = response.parsed_body

    refute json.key?('registrant_type')
    assert_equal 'ACME OÜ', json['registrant']
  end

  def test_volunteered_org_attributes_are_visible_without_captcha
    record = whois_records(:policy_org_owned)
    record.update!(json: record.json.merge(
      'registrant_publishable' => true,
      'registrant_disclosed_attributes' => %w[name email phone]
    ))

    get '/v1/policy-org.test', params: { format: :json }

    assert_equal 'ACME OÜ', response.parsed_body['registrant']
    assert_equal 'owner@policy-org.test', response.parsed_body['email']
    assert_equal '+372 500 0000', response.parsed_body['phone']
    assert_equal disclosable_mask, response.parsed_body['registrant_reg_no']
  end

  def test_consent_withdrawal_masks_private_data_even_when_arrays_remain
    record = whois_records(:policy_priv_owned)
    data = record.json.merge(
      'registrant_publishable' => true,
      'registrant_disclosed_attributes' => %w[name email phone]
    )
    %w[admin_contacts tech_contacts].each do |key|
      data[key][0].merge!('kind' => 'priv', 'contact_publishable' => true,
                         'disclosed_attributes' => %w[name email phone])
    end
    record.update!(json: data)

    get '/v1/policy-priv.test', params: { format: :json }
    assert_equal 'Peeter Pera', response.parsed_body['registrant']
    assert_equal 'Admin Priv', response.parsed_body['admin_contacts'][0]['name']
    assert_equal 'Tech Org', response.parsed_body['tech_contacts'][0]['name']

    data['registrant_publishable'] = false
    %w[admin_contacts tech_contacts].each { |key| data[key][0]['contact_publishable'] = false }
    record.update!(json: data)

    [false, true].each do |detailed|
      solve_captcha if detailed
      get '/v1/policy-priv.test', params: { format: :json }
      json = response.parsed_body

      %w[registrant email phone].each { |key| assert_equal undisclosable_mask, json[key] }
      %w[admin_contacts tech_contacts].each do |key|
        %w[name email phone changed].each do |attr|
          assert_equal undisclosable_mask, json[key][0][attr]
        end
      end
    end
  end

  def test_missing_consent_flag_or_array_fails_closed
    record = whois_records(:policy_priv_owned)
    original = record.json

    %w[flag array].each do |missing|
      data = original.deep_dup
      data['registrant_publishable'] = true
      data['registrant_disclosed_attributes'] = %w[name email phone]
      data.delete(missing == 'flag' ? 'registrant_publishable' : 'registrant_disclosed_attributes')
      %w[admin_contacts tech_contacts].each do |key|
        contact = data[key][0]
        contact.merge!('kind' => 'priv', 'contact_publishable' => true,
                       'disclosed_attributes' => %w[name email phone])
        contact.delete(missing == 'flag' ? 'contact_publishable' : 'disclosed_attributes')
      end
      record.update!(json: data)

      get '/v1/policy-priv.test', params: { format: :json }
      json = response.parsed_body
      %w[registrant email phone].each { |key| assert_equal undisclosable_mask, json[key] }
      %w[admin_contacts tech_contacts].each do |key|
        %w[name email phone].each { |attr| assert_equal undisclosable_mask, json[key][0][attr] }
      end
    end
  end

  def test_privileged_level_reveals_private_data_without_consent
    ENV['whitelist_ip'] = '127.0.0.1'

    get '/v1/policy-priv.test', params: { format: :json }
    json = response.parsed_body

    assert_equal 'Peeter Pera', json['registrant']
    assert_equal 'owner@policy-priv.test', json['email']
    assert_equal '+372 500 0000', json['phone']
    assert_equal '2018-04-25T14:10:39+00:00', json['registrant_changed']
    assert_equal 'Admin Priv', json['admin_contacts'][0]['name']
    assert_equal 'admin@policy-priv.test', json['admin_contacts'][0]['email']
    assert_equal '+372 500 0001', json['admin_contacts'][0]['phone']
    assert_equal '2018-04-25T14:10:41+00:00', json['admin_contacts'][0]['changed']
    assert_equal 'private, no-store', response.headers['Cache-Control']
  end

  def test_old_org_blob_does_not_infer_tech_contact_kind_or_phone_match
    solve_captcha

    get '/v1/company-domain.test', params: { format: :json }
    json = response.parsed_body

    assert_equal 'org', json['registrant_type']
    assert_equal 'test', json['registrant']
    assert_equal 'owner@company-domain.test', json['email']
    assert_equal undisclosable_mask, json['phone']
    assert_equal undisclosable_mask, json['tech_contacts'][0]['name']
    assert_equal undisclosable_mask, json['tech_contacts'][0]['email']
  end

  def test_all_inactive_statuses_and_missing_registration_preserve_legacy_json
    record = whois_records(:policy_org_owned)
    original = record.json
    statuses = [Domain::STATUS_BLOCKED, Domain::STATUS_DISCARDED,
                Domain::STATUS_AT_AUCTION, Domain::STATUS_PENDING_REGISTRATION, nil]

    statuses.each do |status|
      data = original.merge('registration_deadline' => '2027-02-01T00:00:00+02:00')
      if status
        data['status'] = ['ok', status]
      else
        data.delete('registered')
      end
      record.update!(json: data)
      DisclosurePolicy.active_from = nil
      get '/v1/policy-org.test', params: { format: :json }
      legacy_body = response.body

      DisclosurePolicy.active_from = 1.minute.ago
      get '/v1/policy-org.test', params: { format: :json }

      assert_equal legacy_body, response.body
      assert_equal '2027-02-01T00:00:00+02:00', response.parsed_body['registration_deadline']
    end
  end

  def test_dispatch_before_at_and_after_activation
    activation = Time.zone.parse('2027-01-18T00:00:00+02:00')
    DisclosurePolicy.active_from = activation
    solve_captcha

    [-1.second, 0.seconds, 1.second].each do |offset|
      travel_to activation + offset do
        get '/v1/policy-org.test', params: { format: :json }

        if offset.negative?
          refute response.parsed_body.key?('registrant_type')
          refute_equal 'private, no-store', response.headers['Cache-Control']
        else
          assert_equal 'org', response.parsed_body['registrant_type']
          assert_equal 'private, no-store', response.headers['Cache-Control']
        end
      end
    end
  end

  def test_activation_is_resolved_once_for_rendering_and_cache_control
    solve_captcha
    calls = 0
    DisclosurePolicy.stub(:active?, -> { calls += 1; calls == 1 }) do
      get '/v1/policy-org.test', params: { format: :json }
    end

    assert_equal 1, calls
    assert_equal 'org', response.parsed_body['registrant_type']
    assert_equal 'private, no-store', response.headers['Cache-Control']
  end

  private

  def disclosable_mask
    'Not Disclosed - Visit www.internet.ee for web-based WHOIS'
  end

  def undisclosable_mask
    'Not Disclosed'
  end
end
