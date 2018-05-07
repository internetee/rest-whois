json.email 'Not Disclosed - Visit www.internet.ee for webbased WHOIS'
json.registrant whois_record.json['registrant']
json.registrant_reg_no whois_record.json['registrant_reg_no']
json.registrant_ident_country_code whois_record.json['registrant_ident_country_code']

json.tech_contacts do
  json.array!(whois_record.json['tech_contacts']) do |_contact|
    json.name 'Not Disclosed - Visit www.internet.ee for webbased WHOIS'
    json.email 'Not Disclosed - Visit www.internet.ee for webbased WHOIS'
    json.changed 'Not Disclosed - Visit www.internet.ee for webbased WHOIS'
  end
end
json.admin_contacts do
  json.array!(whois_record.json['admin_contacts']) do |_contact|
    json.name 'Not Disclosed - Visit www.internet.ee for webbased WHOIS'
    json.email 'Not Disclosed - Visit www.internet.ee for webbased WHOIS'
    json.changed 'Not Disclosed - Visit www.internet.ee for webbased WHOIS'
  end
end
