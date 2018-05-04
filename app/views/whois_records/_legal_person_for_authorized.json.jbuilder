json.email whois_record.json['email']
json.registrant whois_record.json['registrant']
json.registrant_reg_no whois_record.json['registrant_reg_no']
json.registrant_ident_country_code whois_record.json['registrant_ident_country_code']

json.tech_contacts do
  json.array!(whois_record.json['tech_contacts']) do |contact|
    json.name contact['name']
    json.email contact['email']
    json.changed contact['changed']
  end
end
json.admin_contacts do
  json.array!(whois_record.json['admin_contacts']) do |contact|
    json.name contact['name']
    json.email contact['email']
    json.changed contact['changed']
  end
end
