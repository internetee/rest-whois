require 'application_system_test_case'

class SearchTest < ApplicationSystemTestCase
  def test_home_page_has_search_form
    visit root_path
    assert(has_field?('domain_name', type: 'text'))
  end

  def test_non_existing_domain
    visit root_path
    fill_in('domain_name', with: 'some-random-domain.ee')
    click_link_or_button('Lookup')

    assert(has_text?('Domain not found: some-random-domain.ee'))
  end

  def test_existing_domain
    visit root_path
    fill_in('domain_name', with: 'privatedomain.test')
    click_link_or_button('Lookup')

    within '.domain' do
      assert_text 'Name privatedomain.test'
    end
  end
end
