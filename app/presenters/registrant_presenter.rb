class RegistrantPresenter < ContactPresenter
  def name
    # if registrant_is_org?
    #   disclose_data_org_registrant('name')
    # else
    #   publishable_attribute('name')
    # end
    disclose_registrant_data('name')
  end

  def email
    # publishable_attribute('email')
    disclose_registrant_data('email')
  end

  def phone
    publishable_attribute('phone')
  end

  private

  def disclose_registrant_data(attr)
    registrant_is_org? ? disclose_attr(attr) : disclose_data_priv_registrant(attr)
  end

  def disclose_attr(attr)
    if registrant_publishable? || captcha_solved?
      contact.send(attr.to_sym)
    else
      disclosable_mask
    end
  end

  def disclose_data_priv_registrant(attr)
    return unless registrant_is_org?

    return undisclosable_mask unless contact.attribute_disclosed?(attr)
    disclose_attr(attr)
  end

  # ---

  # def unmasked_registrant_attr(attr)
  #   publication_availability = captcha_solved? || registrant_publishable?
  #   available_contact = whois_record.registrant.legal_person? || whois_record.registrant.attribute_disclosed?(attr.to_sym)
  #   middle_result = publication_availability && available_contact

  #   whitelisted_user? || middle_result
  # end

  # def publishable_attribute(attr)
  #   attr = attr.to_sym

  #   if unmasked_registrant_attr(attr)
  #     contact.send(attr)
  #   elsif contact.attribute_disclosed?(attr) && captcha_unsolved?
  #     disclosable_mask
  #   else
  #     whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
  #   end
  # end
end
