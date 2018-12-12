class WhoisRecord < ApplicationRecord
  BLOCKED = 'Blocked'.freeze
  RESERVED = 'Reserved'.freeze
  DISCARDED = 'deleteCandidate'.freeze

  store_accessor :json, %i[disclaimer]

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

  def domain
    deserialize_domain
  end

  def registrar
    deserialize_registrar
  end

  def registrant
    deserialize_registrant
  end

  def admin_contacts
    json['admin_contacts'].map { |serialized_contact| deserialize_contact(serialized_contact) }
  end

  def tech_contacts
    json['tech_contacts'].map { |serialized_contact| deserialize_contact(serialized_contact) }
  end

  private

  def deserialize_domain
    Domain.new(name: json['name'],
               statuses: json['status'],
               registered: json['registered'],
               changed: json['changed'],
               expire: json['expire'],
               outzone: json['outzone'],
               delete: json['delete'])
  end

  def deserialize_registrar
    Registrar.new(name: json['registrar'],
                  website: json['registrar_website'],
                  phone: json['registrar_phone'],
                  last_update: json['registrar_changed'])
  end

  def deserialize_registrant
    Contact.new(name: json['registrant'],
                type: json['registrant_kind'],
                reg_number: json['registrant_reg_no'],
                email: json['email'],
                ident_country: json['registrant_ident_country_code'],
                last_update: json['registrant_changed'])
  end

  def deserialize_contact(serialized_contact)
    Contact.new(name: serialized_contact['name'],
                type: nil,
                reg_number: nil,
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
