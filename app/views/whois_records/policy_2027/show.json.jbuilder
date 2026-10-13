policy = Disclosure::RecordPresenter.new(@whois_record, @disclosure_level)
domain = policy.domain
registrant = policy.registrant
registrar = policy.registrar

json.disclaimer @whois_record.json['disclaimer']
json.status @whois_record.json['status']
if @whois_record.json['registration_deadline'].present?
  json.registration_deadline @whois_record.json['registration_deadline']
end
json.name @whois_record.json['name']

if domain.active?
  json.registered @whois_record.json['registered']
  json.changed domain.changed
  json.expire @whois_record.json['expire']
  json.outzone domain.outzone
  json.delete domain.delete

  json.dnssec_keys policy.dnssec_keys
  json.dnssec_changed policy.dnssec_changed

  json.nameservers @whois_record.json['nameservers']
  json.nameserver_records policy.nameserver_records
  json.nameservers_changed policy.nameservers_changed

  json.registrant registrant.name
  json.registrant_kind @whois_record.json['registrant_kind']
  json.registrant_type registrant.type
  json.registrant_reg_no registrant.reg_number
  json.registrant_ident_country_code registrant.ident_country
  json.registrant_changed registrant.last_update
  json.email registrant.email
  json.phone registrant.phone

  json.tech_contacts do
    json.array!(policy.tech_contacts) do |contact|
      json.name contact.name
      json.email contact.email
      json.phone contact.phone
      json.changed contact.last_update
      json.merge! contact.identification
    end
  end

  json.admin_contacts do
    json.array!(policy.admin_contacts) do |contact|
      json.name contact.name
      json.email contact.email
      json.phone contact.phone
      json.changed contact.last_update
      json.merge! contact.identification
    end
  end

  json.registrar registrar.name
  json.registrar_website registrar.website
  json.registrar_phone registrar.phone
  json.registrar_email registrar.email
  json.registrar_address registrar.address
  json.registrar_changed registrar.last_update

  if @whois_record.contactable?
    json.contact_form_link new_contact_request_url(domain_name: @whois_record.name,
                                                   locale: contact_form_default_locale)
  end
end
