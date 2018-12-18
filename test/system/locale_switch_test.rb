require 'application_system_test_case'

class LocaleSwitchTest < ApplicationSystemTestCase
  setup do
    @original_default_locale = I18n.default_locale
  end

  teardown do
    I18n.default_locale = @original_default_locale
  end

  def test_default_locale
    assert_equal :en, I18n.default_locale
  end

  def test_available_locales
    visit root_url

    within '.locale-switch' do
      assert_link 'ET'
      assert_text 'EN'
      assert_link 'RU'
    end
  end

  def test_current_locale_is_not_clickable
    I18n.default_locale = :en

    visit root_url
    click_link_or_button 'ET'

    within '.locale-switch' do
      assert_no_link 'ET'
    end
  end
end
