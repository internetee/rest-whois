module ApplicationHelper
  def available_locales
    %i[et en ru]
  end

  def body_css_class
    controller_part = controller_path.split('/').map!(&:dasherize)
    action_part = action_name.dasherize
    [controller_part, action_part, 'page'].join('-')
  end
end
