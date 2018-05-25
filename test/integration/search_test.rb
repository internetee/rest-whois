require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest
  def test_root_page_has_search_form
    visit root_path
    assert(has_field?('whois_record_domain_name', type: 'text'))
  end

  def test_root_page_returns_404_when_no_domain_is_found
    visit root_path
    fill_in('whois_record_domain_name', with: 'some-random-domain.ee')
    assert_equal(404, page.status_code)
    assert(has_text?('Whois record for some-random-domain.ee not found.'))
  end

  def test_root_page_returns_404_when_no_domain_is_found
    visit root_path
    fill_in('whois_record_domain_name', with: 'privatedomain.ee')
    click_link_or_button('Submit')
    assert_equal(200, page.status_code)
    assert(has_text?('Contact owner'))
    assert(has_text('Registrant: Private Person'))
  end
end
