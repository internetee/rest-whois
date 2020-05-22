class Domain
  include ActiveModel::Model

  STATUS_BLOCKED = 'Blocked'.freeze
  STATUS_RESERVED = 'Reserved'.freeze
  STATUS_DISCARDED = 'deleteCandidate'.freeze
  STATUS_AT_AUCTION = 'AtAuction'.freeze
  STATUS_PENDING_REGISTRATION = 'PendingRegistration'.freeze
  STATUS_DISPUTED = 'Disputed'.freeze

  INACTIVE_STATUSES = [STATUS_BLOCKED, STATUS_DISCARDED,
                       STATUS_AT_AUCTION, STATUS_PENDING_REGISTRATION].freeze

  private_constant :INACTIVE_STATUSES

  attr_accessor :name
  attr_accessor :statuses
  attr_accessor :registered
  attr_accessor :changed
  attr_accessor :expire
  attr_accessor :outzone
  attr_accessor :delete
  attr_accessor :registration_deadline

  def active?
    return false if registered.blank?

    (statuses & INACTIVE_STATUSES).empty?
  end
end
