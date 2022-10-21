class ContactPresenter
  attr_reader :contact, :view, :whois_record

  delegate :legal_person?, :reg_number, :ident_country, to: :contact

  def initialize(contact, view, whois_record)
    @contact = contact
    @view = view
    @whois_record = whois_record
  end

  def name
    publishable_attribute('name')
  end

  def email
    publishable_attribute('email')
  end

  def phone
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

  def registrant_publishable?
    contact.registrant_publishable
  end

  def contact_publishable?
    contact.contact_publishable
  end
end
