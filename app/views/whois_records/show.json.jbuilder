json.disclaimer @whois_record.json['disclaimer']
json.status @whois_record.json['status']
if @whois_record.json['registration_deadline'].present?
  json.registration_deadline @whois_record.json['registration_deadline']
end
json.partial! @whois_record.partial_name(authorized: @show_sensitive_data),
              locals: { whois_record: @whois_record,
                        show_sensitive_data: @show_sensitive_data,
                        ip_in_whitelist: ip_in_whitelist? }
