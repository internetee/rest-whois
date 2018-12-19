require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  def test_registered
    domain = Domain.new(statuses: %w[active])
    assert domain.registered?

    domain.statuses = %w[deleteCandidate]
    assert_not domain.registered?
  end

  def test_reserved
    domain = Domain.new(statuses: %w[active])
    assert_not domain.reserved?

    # Case does matter; this is how `registry` app generates it.
    domain.statuses = [Domain::STATUS_RESERVED]

    assert domain.reserved?
  end
end
