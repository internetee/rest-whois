class ContactPresenter
  attr_reader :contact, :view, :whois_record

  delegate :legal_person?, :reg_number, :ident_country, to: :contact

  def initialize(contact, view, whois_record)
    @contact = contact
    @view = view
    @whois_record = whois_record
  end

  def name
    return contact.name if unmask_name?

    whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
  end

  def email
    unmasked = whitelisted_user? || ((whois_record.registrant.legal_person? || contact.attribute_disclosed?(:email)) && (captcha_solved? || registrant_publishable?))

    if unmasked
      contact.email
    elsif contact.attribute_disclosed?(:email) && captcha_unsolved?
      disclosable_mask
    else
      whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
    end
  end

  def phone
    unmasked = whitelisted_user? || (contact.attribute_disclosed?(:phone) && (captcha_solved? || registrant_publishable?))

    if unmasked
      contact.phone
    elsif contact.attribute_disclosed?(:phone) && captcha_unsolved?
      disclosable_mask
    else
      undisclosable_mask
    end
  end

  def last_update
    unmasked = whitelisted_user? || (whois_record.registrant.legal_person? && captcha_solved?)

    if unmasked
      view.l(contact.last_update.to_datetime, default: nil)
    else
      whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
    end
  end


  private

  def unmask_name?    
    whitelisted_user? || ((whois_record.registrant.legal_person? ||
      contact.attribute_disclosed?(:name)) && (captcha_solved? || registrant_publishable?))
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
    whois_record.registrant.registrant_publishable
  end
end
