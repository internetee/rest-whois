class WhoisRecord < ActiveRecord::Base
  establish_connection :production_read_only if Rails.env.production?

  BLOCKED = 'Blocked'.freeze
  RESERVED = 'Reserved'.freeze
  DISCARDED = 'deleteCandidate'.freeze

  def private_person?
    json['registrant_kind'] != 'org'
  end

  def partial_name(authorized = false)
    if discarded_blocked_or_reserved?
      'discarded'
    else
      partial_for_private_person(authorized)
    end
  end

  def contactable?
    !discarded_blocked_or_reserved? && private_person?
  end

  private

  def discarded_blocked_or_reserved?
    !([BLOCKED, RESERVED, DISCARDED] & json['status']).empty?
  end

  def partial_for_private_person(authorized)
    if private_person?
      'private_person'
    elsif authorized
      'legal_person_for_authorized'
    else
      'legal_person'
    end
  end
end
