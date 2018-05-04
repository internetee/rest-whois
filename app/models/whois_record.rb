class WhoisRecord < ActiveRecord::Base
  def private_person?
    json['registrant_kind'] != 'org'
  end

  def partial_name(authorized = false)
    if private_person?
      'private_person'
    else
      if authorized
        'legal_person_for_authorized'
      else
        'legal_person'
      end
    end
  end
end
