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

  def test_registered
    domain = Domain.new(statuses: %w[active])
    assert domain.registered?

    domain.statuses = [Domain::STATUS_DISCARDED]
    assert_not domain.registered?
  end

  def test_reserved
    domain = Domain.new(statuses: %w[active])
    assert_not domain.reserved?

    domain.statuses = [Domain::STATUS_RESERVED]

    assert domain.reserved?
  end
end
