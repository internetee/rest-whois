class RegistrantPresenter < ContactPresenter
  def name
    if registrant_is_org?
      contact.name
    else
      disclose_data_priv_registrant('name')
    end
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
    if captcha_solved?
      contact.last_update
    else
      disclosable_mask
    end
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
    return undisclosable_mask unless contact.attribute_disclosed?(attr)
    disclose_attr(attr)
  end
end
