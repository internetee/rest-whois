class WhoisRecord < ApplicationRecord
  store_accessor :json, %i[disclaimer]

  def private_person?
    json['registrant_kind'] != 'org'
  end

  def partial_name(authorized = false)
    if domain.active?
      partial_for_private_person(authorized)
    else
      'discarded'
    end
  end

  def contactable?
    domain.active? && private_person?
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

  # rubocop:disable Metrics/AbcSize
  def deserialize_domain
    Domain.new(name: json['name'],
               statuses: json['status'],
               registered: json['registered'],
               changed: json['changed'],
               expire: json['expire'],
               outzone: json['outzone'],
               delete: json['delete'],
               registration_deadline: json['registration_deadline']
                                          .try(:to_datetime)
                                          .try(:to_s, :iso8601))
  end
  # rubocop:enable Metrics/AbcSize

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
                last_update: json['registrant_changed'],
                disclosed_attributes: json['registrant_disclosed_attributes'])
  end

  def deserialize_contact(serialized_contact)
    Contact.new(name: serialized_contact['name'],
                type: nil,
                reg_number: nil,
                email: serialized_contact['email'],
                last_update: serialized_contact['changed'],
                disclosed_attributes: serialized_contact['disclosed_attributes'])
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
