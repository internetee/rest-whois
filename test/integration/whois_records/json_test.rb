require 'test_helper'

class JsonTest < ActionDispatch::IntegrationTest
  def test_JSON_does_not_include_disclosed_field_when_not_on_whitelist
    get('/v1/domain.test.json', {}, { 'REMOTE_ADDR': '1.2.3.4' })

    response_json = JSON.parse(response.body)
    assert_equal('1.2.3.4', request.remote_ip)
    assert_equal('Not Disclosed', response_json['email'])
  end

  def test_JSON_includes_disclosed_field_when_on_whitelist
    get('/v1/domain.test.json')

    response_json = JSON.parse(response.body)
    assert_equal('127.0.0.1', request.remote_ip)
    assert_equal('test@test.com', response_json['email'])
  end

  def test_JSON_fields
    expected_response = {
      'admin_contacts': [{'changed': '2018-04-25T14:10:41+03:00',
                          'email': 'test@test.com',
                          'name': 'test'}],
      'changed': '2018-04-25T14:10:41+03:00',
      'delete': nil,
      'disclaimer': 'The information obtained through .ee WHOIS is subject to database protection according to the Estonian Copyright Act and international conventions. All rights are reserved to Estonian Internet Foundation. Search results may not be used for commercial,advertising, recompilation, repackaging, redistribution, reuse, obscuring or other similar activities. Downloading of information about domain names for the creation of your own database is not permitted. If any of the information from .ee WHOIS is transferred to a third party, it must be done in its entirety. This server must not be used as a backend for a search engine.',
      'dnssec_changed': nil,
      'dnssec_keys': [],
      'email': 'test@test.com',
      'expire': '2018-07-25',
      'name': 'domain.test',
      'nameservers': [],
      'nameservers_changed': nil,
      'outzone': nil,
      'registered': '2018-04-25T14:10:41+03:00',
      'registrant': 'test',
      'registrant_changed': '2018-04-25T14:10:39+03:00',
      'registrant_kind': 'priv',
      'registrar': 'test',
      'registrar_address': 'test, test, test, test',
      'registrar_changed': '2018-04-25T14:10:39+03:00',
      'registrar_phone': nil,
      'registrar_website': nil,
      'status': ['inactive'],
      'tech_contacts': [{'changed': '2018-04-25T14:10:41+03:00',
                         'email': 'test@test.com',
                         'name': 'test'}]
    }.with_indifferent_access

    get('/v1/domain.test.json')
    response_json = JSON.parse(response.body)
    assert_equal(expected_response, response_json)
  end
end
