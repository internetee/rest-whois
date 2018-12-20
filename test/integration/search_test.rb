require 'test_helper'

class SearchIntegrationTest < ActionDispatch::IntegrationTest
  def test_home_page_search_returns_404_when_no_domain_is_found
    visit root_path
    fill_in('domain_name', with: 'some-random-domain.ee')
    click_link_or_button('Lookup')
    assert_equal(404, page.status_code)
  end

  def test_home_page_search_returns_404_for_not_domains
    visit root_path
    fill_in('domain_name', with: '1234 ')
    click_link_or_button('Lookup')
    assert_equal(404, page.status_code)
  end

  def test_home_page_search_returns_200_when_domain_is_found
    visit root_path
    fill_in('domain_name', with: 'privatedomain.test')
    click_link_or_button('Lookup')
    assert_equal(200, page.status_code)
  end
end
