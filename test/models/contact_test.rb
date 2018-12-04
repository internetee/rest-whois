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
end
