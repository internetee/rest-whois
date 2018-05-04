json.email "Not Disclosed"
json.registrant "Private Person"
json.tech_contacts do
  json.array!(whois_record.json['tech_contacts']) do |contact|
    json.name "Not Disclosed"
    json.email "Not Disclosed"
    json.changed "Not Disclosed"
  end
end
json.admin_contacts do
  json.array!(whois_record.json['admin_contacts']) do |contact|
    json.name "Not Disclosed"
    json.email "Not Disclosed"
    json.changed "Not Disclosed"
  end
end
