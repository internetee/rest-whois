class RegistrantPresenter < ContactPresenter
  def name
    publishable_attribute('name')
    # unmasked = whitelisted_user? || ((whois_record.registrant.legal_person? || whois_record.registrant.attribute_disclosed?(:name)) && (captcha_solved? || registrant_publishable?))
  
    # if unmasked
    #   contact.name
    # elsif contact.attribute_disclosed?(:name) && captcha_unsolved?
    #   disclosable_mask
    # else
    #   whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
    # end
  end

  def email
    publishable_attribute('email')
    # unmasked = whitelisted_user? || ((whois_record.registrant.legal_person? || whois_record.registrant.attribute_disclosed?(:email)) && (captcha_solved? || registrant_publishable?))
  
    # if unmasked
    #   contact.email
    # elsif contact.attribute_disclosed?(:email) && captcha_unsolved?
    #   disclosable_mask
    # else
    #   whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
    # end
  end

  def phone
    # unmasked = whitelisted_user? || ((whois_record.registrant.legal_person? || whois_record.registrant.attribute_disclosed?(:phone)) && (captcha_solved? || registrant_publishable?))
  
    # if unmasked
    #   contact.phone
    # elsif contact.attribute_disclosed?(:phone) && captcha_unsolved?
    #   disclosable_mask
    # else
    #   whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
    # end

    publishable_attribute('phone')
  end


  private


  def unmasked_registrant_attr(attr)
    whitelisted_user? || ((whois_record.registrant.legal_person? || whois_record.registrant.attribute_disclosed?(attr)) && (captcha_solved? || registrant_publishable?))
  end

  def publishable_attribute(attr)
    # unmasked = unmasked_attr(attr)
    attr = attr.to_sym
    if unmasked_registrant_attr(attr)
      contact.send(attr)
    elsif contact.attribute_disclosed?(attr) && captcha_unsolved?
      disclosable_mask
    else
      whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
    end
  end

  def name_mask
    view.t('masks.undisclosable_registrant_name')
  end
end
