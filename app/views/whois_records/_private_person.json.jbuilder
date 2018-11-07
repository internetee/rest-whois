registrant = RegistrantJSONPresenter.new(@whois_record.registrant, self)
json.name whois_record.json['name']
json.changed whois_record.json['changed']
json.delete whois_record.json['delete']
json.dnssec_changed whois_record.json['dnssec_changed']
json.dnssec_keys whois_record.json['dnssec_keys']
json.expire whois_record.json['expire']
json.nameservers whois_record.json['nameservers']
json.nameservers_changed whois_record.json['nameservers_changed']
json.outzone whois_record.json['outzone']
json.registered whois_record.json['registered']

json.registrant_changed(registrant.last_update)
json.registrant_kind whois_record.json['registrant_kind']

json.registrar whois_record.json['registrar']
json.registrar_address whois_record.json['registrar_address']
json.registrar_changed whois_record.json['registrar_changed']
json.registrar_phone whois_record.json['registrar_phone']
json.registrar_website whois_record.json['registrar_website']

json.email(registrant.email)
json.registrant(registrant.name)

json.tech_contacts do
  json.array!(whois_record.tech_contacts) do |contact|
    contact = ContactJSONPresenter.new(contact, self)
    json.name(contact.name)
    json.email(contact.email)
    json.changed(contact.last_update)
  end
end

json.admin_contacts do
  json.array!(whois_record.admin_contacts) do |contact|
    contact = ContactJSONPresenter.new(contact, self)
    json.name(contact.name)
    json.email(contact.email)
    json.changed(contact.last_update)
  end
end

json.contact_form_link new_contact_request_url(domain_name: whois_record.name,
                                               locale: contact_form_default_locale)
