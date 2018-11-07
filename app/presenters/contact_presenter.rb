class ContactPresenter
  def initialize(contact, view)
    @contact = contact
    @view = view
  end

  def name
    if whitelisted_user?
      contact.name
    else
      name_mask
    end
  end

  def email
    if whitelisted_user?
      contact.email
    else
      undisclosable_mask
    end
  end

  def last_update
    if whitelisted_user?
      view.l(contact.last_update, default: nil)
    else
      undisclosable_mask
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
    undisclosable_mask
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
end
