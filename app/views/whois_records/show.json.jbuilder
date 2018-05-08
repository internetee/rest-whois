json.disclaimer @whois_record.json['disclaimer']
json.status @whois_record.json['status']
json.partial! @whois_record.partial_name(@whitelist), locals: { whois_record: @whois_record }
