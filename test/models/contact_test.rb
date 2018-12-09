require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def test_private_person
    contact = Contact.new

    contact.type = 'priv'
    assert contact.private_person?

    contact.type = 'birthday'
    assert contact.private_person?

    contact.type = 'passport'
    assert contact.private_person?

    contact.type = 'org'
    assert_not contact.private_person?
  end

  def test_legal_person
    contact = Contact.new

    contact.type = 'org'
    assert contact.legal_person?

    contact.type = 'priv'
    assert_not contact.legal_person?

    contact.type = 'birthday'
    assert_not contact.legal_person?

    contact.type = 'passport'
    assert_not contact.legal_person?
  end

  def test_discloses_attributes
    contact = Contact.new(disclosed_attributes: [])
    assert_not contact.attribute_disclosed?(:name)

    contact.disclosed_attributes = %w[name]
    assert contact.attribute_disclosed?(:name)
  end
end
