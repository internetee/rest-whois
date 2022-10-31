class ContactPresenter
  attr_reader :contact, :view, :whois_record

  delegate :legal_person?, :reg_number, :ident_country, to: :contact

  def initialize(contact, view, whois_record)
    @contact = contact
    @view = view
    @whois_record = whois_record
  end

  def registrant_is_org?
    !whois_record.registrant.private_person?
  end

  def registrant_publishable?
    whois_record.registrant.registrant_publishable
  end

  def name
    registrant_is_org? ? disclose_attr_for_org_registrant('name') : publishable_attribute('name')
    # publishable_attribute('name')
  end

  def email
    registrant_is_org? ? disclose_attr_for_org_registrant('email') : publishable_attribute('email')
    # publishable_attribute('email')
  end

  def phone
    # registrant_is_org? ? disclose_attr_for_org_registrant('phone') : publishable_attribute('phone')
    publishable_attribute('phone')
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

  def disclose_attr_for_org_registrant(attr)
    return unless registrant_is_org?

    p '------'
    p whois_record.registrant
    p '-------'
    # attr = attr.to_sym
    # if contact.private_person?
    #   publishable_attribute(attr)
    # else
    #   registrant_publishable? ? contact.send(attr.to_sym) : registrant_resolve_captcha(attr.to_sym)
    # end

    if contact_publishable? || captcha_solved?
      contact.send(attr.to_sym)
    else
      disclosable_mask
    end
  end

  def registrant_resolve_captcha(attr)
    # attr = attr.to_sym

    captcha_solved? ? contact.send(attr) : disclosable_mask
  end

  def unmasked_attr(attr)
    publication_availability = captcha_solved? || contact_publishable?
    available_contact = contact.legal_person? || contact.attribute_disclosed?(attr.to_sym)
    middle_result = publication_availability && available_contact

    whitelisted_user? || middle_result
  end

  def publishable_attribute(attr)
    attr = attr.to_sym

    if unmasked_attr(attr)
      contact.send(attr)
    elsif contact.attribute_disclosed?(attr) && captcha_unsolved?
      disclosable_mask
    else
      undisclosable_mask
    end
  end

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

  def contact_publishable?
    contact.contact_publishable
  end
end
