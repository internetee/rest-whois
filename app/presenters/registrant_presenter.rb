class RegistrantPresenter < ContactPresenter
  def name
    if registrant_is_org?
      contact.name
    else
      publishable_attribute('name')
    end
  end

  def email
    publishable_attribute('email')
  end

  def phone
    publishable_attribute('phone')
  end

  private

  def unmasked_registrant_attr(attr)
    publication_availability = captcha_solved? || registrant_publishable?
    available_contact = whois_record.registrant.legal_person? || whois_record.registrant.attribute_disclosed?(attr.to_sym)
    middle_result = publication_availability && available_contact

    whitelisted_user? || middle_result
  end

  def publishable_attribute(attr)
    attr = attr.to_sym

    if unmasked_registrant_attr(attr)
      contact.send(attr)
    elsif contact.attribute_disclosed?(attr) && captcha_unsolved?
      disclosable_mask
    else
      whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
    end
  end
end
