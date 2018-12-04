require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest
  def test_home_page_has_search_form
    visit root_path
    assert(has_field?('domain_name', type: 'text'))
  end

  def test_home_page_search_returns_404_when_no_domain_is_found
    visit root_path
    fill_in('domain_name', with: 'some-random-domain.ee')
    click_link_or_button('Lookup')
    assert_equal(404, page.status_code)
    assert(has_text?('Domain not found: some-random-domain.ee'))
  end

  def test_home_page_search_returns_404_for_not_domains
    visit root_path
    fill_in('domain_name', with: '1234 ')
    click_link_or_button('Lookup')
    assert_equal(404, page.status_code)
    assert(has_text?('Domain not found: 1234'))
  end

  def test_home_page_search_returns_200_when_domain_is_found
    visit root_path
    fill_in('domain_name', with: 'privatedomain.test')
    click_link_or_button('Lookup')
    assert_equal(200, page.status_code)

    within '.domain' do
      assert_text 'Name privatedomain.test'
    end
  end
end
