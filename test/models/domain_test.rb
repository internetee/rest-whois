require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  def test_status_blocked
    # Case does matter; this is how `registry` app generates it.
    assert_equal 'Blocked', Domain::STATUS_BLOCKED
  end

  def test_status_reserved
    # Case does matter; this is how `registry` app generates it.
    assert_equal 'Reserved', Domain::STATUS_RESERVED
  end

  def test_status_discarded
    # Case does matter; this is how `registry` app generates it.
    assert_equal 'deleteCandidate', Domain::STATUS_DISCARDED
  end

  def test_active
    domain = Domain.new(statuses: %w[ok])
    assert domain.active?
  end

  def test_inactive_when_blocked
    domain = Domain.new(statuses: [Domain::STATUS_BLOCKED])
    assert_not domain.active?
  end

  # A domain in `rest-whois` app can  either be registered or reserved, but in general,
  # a reserved domain _can_ be registered
  def test_inactive_when_reserved
    domain = Domain.new(statuses: [Domain::STATUS_RESERVED])
    assert_not domain.active?
  end

  def test_inactive_when_discarded
    domain = Domain.new(statuses: [Domain::STATUS_DISCARDED])
    assert_not domain.active?
  end
end
