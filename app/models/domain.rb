class Domain
  include ActiveModel::Model

  STATUS_BLOCKED = 'Blocked'.freeze
  STATUS_RESERVED = 'Reserved'.freeze
  STATUS_DISCARDED = 'deleteCandidate'.freeze

  attr_accessor :name
  attr_accessor :statuses
  attr_accessor :registered
  attr_accessor :changed
  attr_accessor :expire
  attr_accessor :outzone
  attr_accessor :delete

  def registered?
    statuses.exclude?(STATUS_DISCARDED)
  end

  def reserved?
    statuses.include?(STATUS_RESERVED)
  end
end
