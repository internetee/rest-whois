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

  def test_deserializes_registrant
    whois_record = WhoisRecord.new(json: { registrant: 'John',
                                           registrant_kind: 'priv',
                                           email: 'john@shop.test',
                                           registrant_changed: '2010-07-05T00:00:00+00:00' })
    assert_equal Contact.new(name: 'John',
                             type: 'priv',
                             email: 'john@shop.test',
                             last_update: Time.zone.parse('2010-07-05')), whois_record.registrant
  end

  def test_deserializes_admin_contacts
    whois_record = WhoisRecord.new(json: { admin_contacts: [{ name: 'John',
                                                              type: nil,
                                                              email: 'john@shop.test',
                                                              changed: '2010-07-05T00:00:00+00:00'
                                                            }] })
    assert_equal [Contact.new(name: 'John',
                              type: nil,
                              email: 'john@shop.test',
                              last_update: Time.zone.parse('2010-07-05'))],
                 whois_record.admin_contacts
  end

  def test_deserializes_tech_contacts
    whois_record = WhoisRecord.new(json: { tech_contacts: [{ name: 'John',
                                                             type: nil,
                                                             email: 'john@shop.test',
                                                             changed: '2010-07-05T00:00:00+00:00'
                                                           }] })
    assert_equal [Contact.new(name: 'John',
                              type: nil,
                              email: 'john@shop.test',
                              last_update: Time.zone.parse('2010-07-05'))],
                 whois_record.tech_contacts
  end
end
