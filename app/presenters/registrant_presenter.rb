class RegistrantPresenter < ContactPresenter
  private

  def name_mask
    view.t('masks.undisclosable_registrant_name')
  end
end
