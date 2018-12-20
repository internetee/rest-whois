class RegistrantPresenter < ContactPresenter
  def name
    unmasked = whitelisted_user? || whois_record.registrant.legal_person? ||
               contact.attribute_disclosed?(:name)

    if unmasked
      contact.name
    else
      name_mask
    end
  end

  private

  def name_mask
    view.t('masks.undisclosable_registrant_name')
  end
end
