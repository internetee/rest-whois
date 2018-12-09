class ContactPresenter
  delegate :legal_person?, :reg_number, :ident_country, to: :contact

  def initialize(contact, view, whois_record)
    @contact = contact
    @view = view
    @whois_record = whois_record
  end

  def name
    unmasked = whitelisted_user? || (whois_record.registrant.legal_person? && captcha_solved?) ||
               contact.attribute_disclosed?(:name)

    if unmasked
      contact.name
    else
      whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
    end
  end

  def email
    unmasked = whitelisted_user? || (whois_record.registrant.legal_person? && captcha_solved?) ||
               (contact.attribute_disclosed?(:email) && captcha_solved?)

    if unmasked
      contact.email
    elsif contact.attribute_disclosed?(:email) && captcha_unsolved?
      disclosable_mask
    else
      whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
    end
  end

  def last_update
    unmasked = whitelisted_user? || (whois_record.registrant.legal_person? && captcha_solved?)

    if unmasked
      view.l(contact.last_update, default: nil)
    else
      whois_record.registrant.private_person? ? undisclosable_mask : disclosable_mask
    end
  end

  private

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

  attr_reader :contact
  attr_reader :view
  attr_reader :whois_record
end
