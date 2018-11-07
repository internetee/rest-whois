class WhoisRecord < ApplicationRecord
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

  def registrant
    deserialized_registrant
  end

  def admin_contacts
    json['admin_contacts'].map { |serialized_contact| deserialized_contact(serialized_contact) }
  end

  def tech_contacts
    json['tech_contacts'].map { |serialized_contact| deserialized_contact(serialized_contact) }
  end

  private

  def deserialized_registrant
    Contact.new(name: json['registrant'],
                type: json['registrant_kind'],
                email: json['email'],
                last_update: json['registrant_changed'])
  end

  def deserialized_contact(serialized_contact)
    Contact.new(name: serialized_contact['name'],
                type: nil,
                email: serialized_contact['email'],
                last_update: serialized_contact['changed'])
  end

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
