class RegistrantJSONPresenter < RegistrantPresenter
  def last_update
    if whitelisted_user?
      contact.last_update
    else
      undisclosable_mask
    end
  end
end
