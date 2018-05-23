module ApplicationHelper
  def allowed_locales
    [:et, :en, :ru]
  end

  def other_locales
    allowed_locales - [I18n.locale]
  end
end
