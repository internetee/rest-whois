require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  def test_registered
    domain = Domain.new(statuses: %w[active])
    assert domain.registered?

    domain.statuses = %w[deleteCandidate]
    assert_not domain.registered?
  end
end
