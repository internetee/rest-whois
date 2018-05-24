json.disclaimer @whois_record.json['disclaimer']
json.status @whois_record.json['status']
json.partial! @whois_record.partial_name(@show_sensitive_data),
              locals: { whois_record: @whois_record,
                        show_sensitive_data: @show_sensitive_data,
                        ip_in_whitelist: ip_in_whitelist? }
