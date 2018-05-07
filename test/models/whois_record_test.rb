class WhoisRecordTest < ActiveSupport::TestCase
  def setup
    super

    @private_domain = whois_records(:privately_owned)
    @legal_domain = whois_records(:legally_owned)
  end

  def test_private_person_returns_a_boolean
    refute(@legal_domain.private_person?)
    assert(@private_domain.private_person?)
  end

  def test_partial_name_for_private_person
    assert_equal('private_person', @private_domain.partial_name)
    assert_equal('private_person', @private_domain.partial_name(true))
  end

  def test_partial_name_for_legal_person
    assert_equal('legal_person', @legal_domain.partial_name)
    assert_equal('legal_person_for_authorized', @legal_domain.partial_name(true))
  end
end
