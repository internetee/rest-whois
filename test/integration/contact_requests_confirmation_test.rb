# encoding: utf-8
require 'test_helper'

class ContactRequestsConfirmationIntegrationTest < ActionDispatch::IntegrationTest
  def test_new_request_fails_if_there_is_no_domain_name_passed
    assert_raise ActiveRecord::RecordNotFound do
      get(new_contact_request_path)
    end
  end

  def test_new_request_fails_if_that_is_a_discarded_domain
    assert_raise ActiveRecord::RecordNotFound do
      get(new_contact_request_path(params: { domain_name: 'discarded-domain.test' }))
      assert_response :not_found
    end
  end

  def test_redirects_to_main_path_when_button_clicked
    main_url = 'https://internet.ee/'
    ENV['main_page_url'] = main_url

    stub_request(:any, main_url).to_return(body: 'Success')

    visit new_contact_request_path(params: { domain_name: 'privatedomain.test' })

    fill_in('contact_request[email]', with: 'i-want-to-contact-you@domain.com')
    fill_in('contact_request[name]', with: 'Test User')
    click_link_or_button 'Get a link'

    assert_text('Check your email for a link to the one-time contact form.')

    click_link_or_button 'Back to previous page'
    assert_equal main_url, current_url
  end
end
