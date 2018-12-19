class Domain
  include ActiveModel::Model

  # Case does matter; this is how `registry` app generates it.
  STATUS_RESERVED = 'Reserved'

  attr_accessor :name
  attr_accessor :statuses
  attr_accessor :registered
  attr_accessor :changed
  attr_accessor :expire
  attr_accessor :outzone
  attr_accessor :delete

  def registered?
    statuses.exclude?('deleteCandidate')
  end

  def reserved?
    statuses.include?(STATUS_RESERVED)
  end
end
