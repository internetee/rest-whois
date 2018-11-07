require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  setup do
    @contact = Contact.new(name: 'test', type: 'priv', email: 'test', last_update: 'test')
  end

  def test_two_contacts_with_the_same_attributes_are_equal
    assert_equal Contact.new(name: 'test', type: 'priv', email: 'test', last_update: 'test'),
                 @contact
  end

  def test_two_contacts_with_different_attributes_are_not_equal
    assert_not_equal Contact.new(name: 'other', type: 'priv', email: 'test', last_update: 'test'),
                     @contact
  end
end
