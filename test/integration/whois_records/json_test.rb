require 'test_helper'

class WhoisRecordJsonTest < ActionDispatch::IntegrationTest
  # By default, all requests are done from 127.0.0.1, which is inside the
  # whitelist
  def test_JSON_does_not_include_disclosed_field_when_not_on_whitelist
    get('/v1/company-domain.test.json', {}, { 'REMOTE_ADDR': '1.2.3.4' })

    response_json = JSON.parse(response.body)
    assert_equal('1.2.3.4', request.remote_ip)
    assert_equal('Not Disclosed - Visit www.internet.ee for webbased WHOIS', response_json['email'])
  end

  def test_json_returns_404_for_missing_domains
    get('/v1/missing-domain.test.json')

    assert_equal(404, response.status)
    response_json = JSON.parse(response.body)
    assert_equal('Domain not found.', response_json['error'])
    assert_equal('missing-domain.test', response_json['name'])
  end

  def test_POST_requests_works_as_get
    post('/v1/missing-domain.test.json')

    assert_equal(404, response.status)
    response_json = JSON.parse(response.body)
    assert_equal('Domain not found.', response_json['error'])
    assert_equal('missing-domain.test', response_json['name'])
  end

  def test_json_includes_disclosed_field_when_on_whitelist
    get('/v1/company-domain.test.json')

    response_json = JSON.parse(response.body)
    assert_equal('127.0.0.1', request.remote_ip)
    assert_equal('owner@company-domain.test', response_json['email'])
  end

  def test_JSON_does_not_include_private_person_contact_data
    get('/v1/privatedomain.test.json')

    response_json = JSON.parse(response.body)
    assert_equal('127.0.0.1', request.remote_ip)
    assert_equal('Not Disclosed', response_json['email'])
    assert_equal('Private Person', response_json['registrant'])
  end

  def test_JSON_includes_legal_person_contacts_data
    get('/v1/company-domain.test.json')

    response_json = JSON.parse(response.body)
    assert_equal('127.0.0.1', request.remote_ip)
    assert_equal('owner@company-domain.test', response_json['email'])
    assert_equal('test', response_json['registrant'])

    expected_admin_contacts = [
      { 'name': 'Admin Contact',
        'email': 'admin-contact@company-domain.test',
        'changed': '2018-04-25T14:10:41+03:00' }.with_indifferent_access
    ]

    expected_tech_contacts = [
      { 'name': 'Tech Contact',
        'email': 'tech-contact@company-domain.test',
        'changed': '2018-04-25T14:10:41+03:00' }.with_indifferent_access
    ]

    assert_equal(expected_admin_contacts, response_json['admin_contacts'])
    assert_equal(expected_tech_contacts, response_json['tech_contacts'])
  end

  def test_JSON_all_fields_are_present
    expected_response = {
      'admin_contacts': [{'changed': 'Not Disclosed',
                          'email': 'Not Disclosed',
                          'name': 'Not Disclosed'}],
      'changed': '2018-04-25T14:10:41+03:00',
      'delete': nil,
      'disclaimer': 'The information obtained through .ee WHOIS is subject to database protection according to the Estonian Copyright Act and international conventions. All rights are reserved to Estonian Internet Foundation. Search results may not be used for commercial,advertising, recompilation, repackaging, redistribution, reuse, obscuring or other similar activities. Downloading of information about domain names for the creation of your own database is not permitted. If any of the information from .ee WHOIS is transferred to a third party, it must be done in its entirety. This server must not be used as a backend for a search engine.',
      'dnssec_changed': nil,
      'dnssec_keys': [],
      'email': 'Not Disclosed',
      'expire': '2018-07-25',
      'name': 'privatedomain.test',
      'nameservers': [],
      'nameservers_changed': nil,
      'outzone': nil,
      'registered': '2018-04-25T14:10:41+03:00',
      'registrant': 'Private Person',
      'registrant_changed': '2018-04-25T14:10:39+03:00',
      'registrant_kind': 'priv',
      'registrar': 'test',
      'registrar_address': 'test, test, test, test',
      'registrar_changed': '2018-04-25T14:10:39+03:00',
      'registrar_phone': nil,
      'registrar_website': nil,
      'status': ['inactive'],
      'tech_contacts': [{'changed': 'Not Disclosed',
                         'email': 'Not Disclosed',
                         'name': 'Not Disclosed'}]
    }.with_indifferent_access

    get('/v1/privatedomain.test.json')
    response_json = JSON.parse(response.body)
    assert_equal(expected_response, response_json)
  end
end
