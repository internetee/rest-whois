require 'test_helper'

class DisclosurePolicyTest < ActiveSupport::TestCase
  setup do
    @original_active_from = DisclosurePolicy.active_from
    @original_env = ENV[DisclosurePolicy::ENV_KEY]
  end

  teardown do
    DisclosurePolicy.active_from = @original_active_from
    ENV[DisclosurePolicy::ENV_KEY] = @original_env
  end

  def test_inactive_when_not_configured
    DisclosurePolicy.active_from = nil

    refute DisclosurePolicy.active?
  end

  def test_inactive_before_activation
    DisclosurePolicy.active_from = Time.zone.parse('2027-01-18T00:00:00+02:00')

    refute DisclosurePolicy.active?(
      Time.zone.parse('2027-01-18T00:00:00+02:00') - 1.second
    )
  end

  def test_active_exactly_at_activation
    active_from = Time.zone.parse('2027-01-18T00:00:00+02:00')
    DisclosurePolicy.active_from = active_from

    assert DisclosurePolicy.active?(active_from)
  end

  def test_active_after_activation
    DisclosurePolicy.active_from = Time.zone.parse('2027-01-18T00:00:00+02:00')

    assert DisclosurePolicy.active?(
      Time.zone.parse('2027-01-18T00:00:00+02:00') + 1.second
    )
  end

  def test_parse_returns_nil_for_blank_values
    assert_nil DisclosurePolicy.parse(nil)
    assert_nil DisclosurePolicy.parse('')
    assert_nil DisclosurePolicy.parse('  ')
  end

  def test_parse_accepts_iso8601_with_offset
    assert_equal Time.iso8601('2027-01-18T00:00:00+02:00'),
                 DisclosurePolicy.parse('2027-01-18T00:00:00+02:00')
    assert_equal Time.iso8601('2027-01-18T00:00:00Z'),
                 DisclosurePolicy.parse('2027-01-18T00:00:00Z')
  end

  def test_parse_raises_on_timestamp_without_offset
    assert_raises(ArgumentError) do
      DisclosurePolicy.parse('2027-01-18T00:00:00')
    end
  end

  def test_parse_raises_on_malformed_value
    error = assert_raises(ArgumentError) { DisclosurePolicy.parse('soon') }

    assert_includes error.message, 'DISCLOSURE_POLICY_ACTIVE_FROM'
  end

  def test_parse_rejects_invalid_dates_and_offsets_instead_of_normalizing_them
    %w[2027-02-30T00:00:00+02:00 2027-01-18T00:00:00+02:99
       2027-01-18T00:00:00+25:00].each do |value|
      assert_raises(ArgumentError) { DisclosurePolicy.parse(value) }
    end
  end

  def test_load_from_env_activates_policy
    ENV[DisclosurePolicy::ENV_KEY] = '2000-01-18T00:00:00+02:00'
    DisclosurePolicy.load_from_env

    assert DisclosurePolicy.active?
  end

  def test_load_from_env_deactivates_policy_when_unset
    ENV.delete(DisclosurePolicy::ENV_KEY)
    DisclosurePolicy.load_from_env

    refute DisclosurePolicy.active?
  end

  def test_load_from_env_deactivates_policy_when_blank
    ENV[DisclosurePolicy::ENV_KEY] = '  '
    DisclosurePolicy.load_from_env

    refute DisclosurePolicy.active?
  end

  def test_load_from_env_rejects_malformed_configuration
    ENV[DisclosurePolicy::ENV_KEY] = '2027-01-18T00:00:00'

    error = assert_raises(ArgumentError) { DisclosurePolicy.load_from_env }
    assert_includes error.message, 'DISCLOSURE_POLICY_ACTIVE_FROM'
    assert_includes error.message, 'explicit offset'
  end
end
