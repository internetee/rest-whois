class RegistrantPresenter < ContactPresenter
  def name
  #   unmasked = whitelisted_user? || whois_record.registrant.legal_person? ||
  #              contact.attribute_disclosed?(:name)

  #   unmasked ? contact.name : name_mask
  unmasked = whitelisted_user? || ((whois_record.registrant.legal_person? || contact.attribute_disclosed?(:name)) && (captcha_solved? || registrant_publishable?))
  
  if unmasked
    contact.name
  elsif contact.attribute_disclosed?(:name) && captcha_unsolved?
    disclosable_mask
  else
    whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
  end
  end

  private

  def name_mask
    view.t('masks.undisclosable_registrant_name')
  end
end
