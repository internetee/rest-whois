require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  def test_statuses
    # Case does matter; this is how `registry` app generates it.
    assert_equal 'Blocked', Domain::STATUS_BLOCKED
    assert_equal 'Reserved', Domain::STATUS_RESERVED
    assert_equal 'deleteCandidate', Domain::STATUS_DISCARDED
    assert_equal 'AtAuction', Domain::STATUS_AT_AUCTION
    assert_equal 'PendingRegistration', Domain::STATUS_PENDING_REGISTRATION
  end

  def test_active
    domain = Domain.new(statuses: %w[ok], registered: Time.now)
    assert domain.active?
  end

  def test_inactive_when_blocked
    domain = Domain.new(statuses: [Domain::STATUS_BLOCKED])
    assert_not domain.active?
  end

  # A domain in `rest-whois` app can  either be registered or reserved, but in general,
  # a reserved domain _can_ be registered
  def test_inactive_when_reserved_and_unregistered
    domain = Domain.new(statuses: [Domain::STATUS_RESERVED])
    assert_not domain.active?
  end

  def test_active_when_reserved_and_registered
    domain = Domain.new(statuses: [Domain::STATUS_RESERVED], registered: Time.now)
    assert domain.active?
  end

  def test_inactive_when_discarded
    domain = Domain.new(statuses: [Domain::STATUS_DISCARDED])
    assert_not domain.active?
  end

  def test_inactive_when_at_auction
    domain = Domain.new(statuses: [Domain::STATUS_AT_AUCTION])
    assert_not domain.active?
  end

  def test_inactive_when_disputed_and_unregistered
    domain = Domain.new(statuses: [Domain::STATUS_DISPUTED])
    assert_not domain.active?
  end

  def test_active_when_disputed_and_registered
    domain = Domain.new(statuses: [Domain::STATUS_DISPUTED], registered: Time.now)
    assert domain.active?
  end

  def test_inactive_when_pending_registration
    domain = Domain.new(statuses: [Domain::STATUS_PENDING_REGISTRATION])
    assert_not domain.active?
  end
end
