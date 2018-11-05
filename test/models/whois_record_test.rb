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
end
