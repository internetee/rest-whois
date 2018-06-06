require 'test_helper'

class LocaleTest < ActionDispatch::IntegrationTest
  def test_home_page_has_working_locale_links
    visit root_path
    assert(has_link?('Eesti'))
    assert(has_link?('по-русски'))
    click_link_or_button('Eesti')
    assert(has_link?('English'))
  end
end
