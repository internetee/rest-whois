class RegistrantPresenter < ContactPresenter
  def name
    registrant_is_org? ? contact.name : disclose_data_priv_registrant('name')
  end

  def email
    # publishable_attribute('email')
    registrant_is_org? ? disclose_attr('email') : disclose_data_priv_registrant('email')
  end

  def phone
    registrant_is_org? ? disclose_registrant_org_phone : disclose_data_priv_registrant('phone')
  end

  def last_update
    captcha_solved? ? contact.last_update : disclosable_mask
  end

  private

  def disclose_attr(attr)
    if whitelisted_user? || registrant_publishable? || captcha_solved?
      contact.send(attr.to_sym)
    else
      disclosable_mask
    end
  end

  def disclose_registrant_org_phone
    phone_disclosed_and_captcha_solved = contact.attribute_disclosed?('phone') && captcha_solved?

    if phone_disclosed_and_captcha_solved || whitelisted_user? || registrant_publishable?
      contact.send('phone')
    elsif !contact.attribute_disclosed?('phone')
      undisclosable_mask
    else
      disclosable_mask
    end
  end

  def disclose_data_priv_registrant(attr)
    return contact.send(attr.to_sym) if whitelisted_user?
    return undisclosable_mask unless contact.attribute_disclosed?(attr)

    disclose_attr(attr)
  end
end
