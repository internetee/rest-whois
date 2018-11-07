class ContactJSONPresenter < ContactPresenter
  def email
    if whitelisted_user?
      contact.email
    else
      undisclosable_mask
    end
  end

  def last_update
    if whitelisted_user?
      contact.last_update
    else
      undisclosable_mask
    end
  end
end
