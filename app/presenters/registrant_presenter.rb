class RegistrantPresenter < ContactPresenter
  def name
    registrant_is_org? ? contact.name : disclose_data_priv_registrant('name')
  end

  def email
    # publishable_attribute('email')
    disclose_registrant_data('email')
  end

  def phone
    # publishable_attribute('phone')
    disclose_data_priv_registrant('phone')
  end

  def last_update
    captcha_solved? ? contact.last_update : disclosable_mask
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
    return contact.send(attr.to_sym) if whitelisted_user?
    return undisclosable_mask unless contact.attribute_disclosed?(attr)

    disclose_attr(attr)
  end
end
