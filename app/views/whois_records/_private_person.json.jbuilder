registrant = RegistrantPresenter.new(@whois_record.registrant, self, whois_record)

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

json.registrant_changed(ip_in_whitelist ? whois_record.json['registrant_changed'] : 'Not Disclosed')
json.registrant_kind whois_record.json['registrant_kind']

json.registrar whois_record.json['registrar']
json.registrar_changed whois_record.json['registrar_changed']
json.registrar_phone whois_record.json['registrar_phone']
json.registrar_website whois_record.json['registrar_website']

json.email(registrant.email)
json.phone(registrant.phone)
json.registrant(registrant.name)

json.tech_contacts do
  json.array!(whois_record.tech_contacts) do |contact|
    contact_presenter = ContactPresenter.new(contact, self, whois_record)
    json.name(contact_presenter.name)
    json.email(contact_presenter.email)
    json.phone(contact_presenter.phone)
    json.changed(ip_in_whitelist ? contact.last_update : 'Not Disclosed')
  end
end

json.admin_contacts do
  json.array!(whois_record.admin_contacts) do |contact|
    contact_presenter = ContactPresenter.new(contact, self, whois_record)
    json.name(contact_presenter.name)
    json.email(contact_presenter.email)
    json.phone(contact_presenter.phone)
    json.changed(ip_in_whitelist ? contact.last_update : 'Not Disclosed')
  end
end

json.contact_form_link new_contact_request_url(domain_name: whois_record.name,
                                               locale: contact_form_default_locale)
