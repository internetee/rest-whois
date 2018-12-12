require 'test_helper'

class WhoisRecordTest < ActiveSupport::TestCase
  def setup
    super

    @private_domain = whois_records(:privately_owned)
    @legal_domain = whois_records(:legally_owned)
    @discarded_domain = whois_records(:discarded)
  end

  def test_private_person_returns_a_boolean
    refute(@legal_domain.private_person?)
    assert(@private_domain.private_person?)
  end

  def test_contactable_returns_a_boolean
    refute(@legal_domain.contactable?)
    refute(@discarded_domain.contactable?)
    assert(@private_domain.contactable?)
  end

  def test_partial_name_for_private_person
    assert_equal('private_person', @private_domain.partial_name)
    assert_equal('private_person', @private_domain.partial_name(true))
  end

  def test_partial_name_for_legal_person
    assert_equal('legal_person', @legal_domain.partial_name)
    assert_equal('legal_person_for_authorized', @legal_domain.partial_name(true))
  end

  def test_partial_name_for_discarded_domain
    assert_equal('discarded', @discarded_domain.partial_name)
    assert_equal('discarded', @discarded_domain.partial_name(true))
  end

  def test_deserializes_disclaimer
    whois_record = WhoisRecord.new(json: { disclaimer: 'test disclaimer' })
    assert_equal 'test disclaimer', whois_record.disclaimer
  end

  def test_deserializes_domain
    whois_record = WhoisRecord.new(json: { name: 'shop.test',
                                           status: %w[active],
                                           registered: '2010-07-05T00:00:00+00:00',
                                           changed: '2010-07-06T00:00:00+00:00',
                                           expire: '2010-07-07T00:00:00+00:00',
                                           outzone: '2010-07-08T00:00:00+00:00',
                                           delete: '2010-07-09T00:00:00+00:00' })

    assert_equal 'shop.test', whois_record.domain.name
    assert_equal %w[active], whois_record.domain.statuses
    assert_equal Time.zone.parse('2010-07-05'), whois_record.domain.registered
    assert_equal Time.zone.parse('2010-07-06'), whois_record.domain.changed
    assert_equal Time.zone.parse('2010-07-07'), whois_record.domain.expire
    assert_equal Time.zone.parse('2010-07-08'), whois_record.domain.outzone
    assert_equal Time.zone.parse('2010-07-09'), whois_record.domain.delete
  end

  def test_deserializes_registrar
    whois_record = WhoisRecord.new(json: { registrar: 'Bestnames',
                                           registrar_website: 'https://bestnames.test',
                                           registrar_phone: '1234',
                                           registrar_changed: '2010-07-05T00:00:00+00:00' })

    assert_equal 'Bestnames', whois_record.registrar.name
    assert_equal 'https://bestnames.test', whois_record.registrar.website
    assert_equal '1234', whois_record.registrar.phone
    assert_equal Time.zone.parse('2010-07-05'), whois_record.registrar.last_update
  end

  def test_deserializes_registrant
    whois_record = WhoisRecord.new(json: { registrant: 'John',
                                           registrant_kind: 'priv',
                                           registrant_reg_no: '1234',
                                           email: 'john@shop.test',
                                           registrant_ident_country_code: 'US',
                                           registrant_changed: '2010-07-05T00:00:00+00:00' })

    assert_equal 'John', whois_record.registrant.name
    assert_equal 'priv', whois_record.registrant.type
    assert_equal '1234', whois_record.registrant.reg_number
    assert_equal 'john@shop.test', whois_record.registrant.email
    assert_equal 'US', whois_record.registrant.ident_country
    assert_equal Time.zone.parse('2010-07-05'), whois_record.registrant.last_update
  end

  def test_deserializes_admin_contacts
    whois_record = WhoisRecord.new(json: { admin_contacts: [{ name: 'John',
                                                              email: 'john@shop.test',
                                                              changed: '2010-07-05T00:00:00+00:00'
                                                            }] })

    contact = whois_record.admin_contacts.first
    assert_equal 'John', contact.name
    assert_equal 'john@shop.test', contact.email
    assert_equal Time.zone.parse('2010-07-05'), contact.last_update
  end

  def test_deserializes_tech_contacts
    whois_record = WhoisRecord.new(json: { tech_contacts: [{ name: 'John',
                                                             email: 'john@shop.test',
                                                             changed: '2010-07-05T00:00:00+00:00'
                                                           }] })

    contact = whois_record.tech_contacts.first
    assert_equal 'John', contact.name
    assert_equal 'john@shop.test', contact.email
    assert_equal Time.zone.parse('2010-07-05'), contact.last_update
  end
end
