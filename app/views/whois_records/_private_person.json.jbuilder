json.name whois_record.json['name']
json.changed whois_record.json['changed']
json.delete whois_record.json['delete']
json.dnssec_changed whois_record.json['dnssec_changed']
json.dnssec_keys whois_record.json['dnssec_keys']
json.expire whois_record.json['expire']
json.name whois_record.json['name']
json.nameservers whois_record.json['nameservers']
json.nameservers_changed whois_record.json['nameservers_changed']
json.outzone whois_record.json['outzone']
json.registered whois_record.json['registered']

json.registrant_changed whois_record.json['registrant_changed']
json.registrant_kind whois_record.json['registrant_kind']

json.registrar whois_record.json['registrar']
json.registrar_address whois_record.json['registrar_address']
json.registrar_changed whois_record.json['registrar_changed']
json.registrar_phone whois_record.json['registrar_phone']
json.registrar_website whois_record.json['registrar_website']

json.email (ip_in_whitelist ? whois_record.json['email'] : 'Not Disclosed')
json.registrant (ip_in_whitelist ? whois_record.json['registrant'] : 'Private Person')

json.tech_contacts do
  json.array!(whois_record.json['tech_contacts']) do |contact|
    json.name (ip_in_whitelist ? contact['name'] : 'Not Disclosed')
    json.email (ip_in_whitelist ? contact['email'] : 'Not Disclosed')
    json.changed (ip_in_whitelist ? contact['changed'] : 'Not Disclosed')
  end
end

json.admin_contacts do
  json.array!(whois_record.json['admin_contacts']) do |contact|
    json.name (ip_in_whitelist ? contact['name'] : 'Not Disclosed')
    json.email (ip_in_whitelist ? contact['email'] : 'Not Disclosed')
    json.changed (ip_in_whitelist ? contact['changed'] : 'Not Disclosed')
  end
end

json.contact_form_link new_contact_request_url({ domain_name: whois_record.name })
