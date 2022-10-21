class ContactPresenter
  attr_reader :contact, :view, :whois_record

  delegate :legal_person?, :reg_number, :ident_country, to: :contact

  def initialize(contact, view, whois_record)
    @contact = contact
    @view = view
    @whois_record = whois_record
  end

  def name
    # unmasked = whitelisted_user? || ((contact.legal_person? || contact.attribute_disclosed?(:name)) && (captcha_solved? || contact_publishable?))

    # if unmasked
    #   contact.name
    # elsif contact.attribute_disclosed?(:name) && captcha_unsolved?
    #   disclosable_mask
    # else
    #   contact.private_person? ? undisclosable_mask : disclosable_mask
    # end
    publishable_attribute('name')
  end

  def email
    # unmasked = whitelisted_user? || ((contact.legal_person? || contact.attribute_disclosed?(:email)) && (captcha_solved? || contact_publishable?))

    # if unmasked
    #   contact.email
    # elsif contact.attribute_disclosed?(:email) && captcha_unsolved?
    #   disclosable_mask
    # else
    #   contact.private_person? ? undisclosable_mask : disclosable_mask
    # end
    publishable_attribute('email')
  end

  def phone
    publishable_attribute('phone')
    # unmasked = whitelisted_user? || (contact.attribute_disclosed?(:phone) && (captcha_solved? || contact_publishable?))

    # if unmasked
    #   contact.phone
    # elsif contact.attribute_disclosed?(:phone) && captcha_unsolved?
    #   disclosable_mask
    # else
    #   undisclosable_mask
    # end
  end

  def last_update
    unmasked = whitelisted_user? || (contact.legal_person? && captcha_solved?)

    if unmasked
      view.l(contact.last_update.to_datetime, default: nil)
    else
      contact.private_person? ? undisclosable_mask : disclosable_mask
    end
  end

  private

  def unmasked_attr(attr)
    whitelisted_user? || ((contact.legal_person? || contact.attribute_disclosed?(attr.to_sym)) && (captcha_solved? || contact_publishable?))
  end

  def publishable_attribute(attr)
    # unmasked = unmasked_attr(attr)
    attr = attr.to_sym
    if unmasked_attr(attr)
      contact.send(attr)
    elsif contact.attribute_disclosed?(attr) && captcha_unsolved?
      disclosable_mask
    else
      undisclosable_mask
    end
  end

  # def unmask_name?
  #   whitelisted_user? || (contact.legal_person? &&
  #     (captcha_solved? || registrant_publishable?)) || contact.attribute_disclosed?(:name)
  # end

  def disclosable_mask
    view.t('masks.disclosable')
  end

  def undisclosable_mask
    view.t('masks.undisclosable')
  end

  def name_mask
    contact.private_person? ? undisclosable_mask : disclosable_mask
  end

  def whitelisted_user?
    view.ip_in_whitelist?
  end

  def captcha_solved?
    view.captcha_solved?
  end

  def captcha_unsolved?
    !captcha_solved?
  end

  def registrant_publishable?
    contact.registrant_publishable
  end

  def contact_publishable?
    contact.contact_publishable
  end
end
