# encoding: utf-8
require 'test_helper'

class ContactRequestsConfirmationIntegrationTest < ActionDispatch::IntegrationTest

  def setup
    super
    @valid_contact_request = contact_requests(:valid)

    stub_request(:put, /http:\/\/registry:3000\/api\/v1\/contact_requests\/\d+/).to_return(status: 200, body: @valid_contact_request.to_json, headers: {})
    stub_request(:post, 'http://registry:3000/api/v1/contact_requests/').to_return(status: 200, body: @valid_contact_request.to_json, headers: {})
  end

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
    main_url = 'https://www.internet.ee/'
    ENV['main_page_url'] = main_url

    stub_request(:any, main_url).to_return(body: 'Success')

    visit new_contact_request_path(params: { domain_name: 'privatedomain.test' })

    fill_in('contact_request[email]', with: @valid_contact_request.email)
    fill_in('contact_request[name]', with: 'Test User')
    click_link_or_button 'Get a link'

    assert_text('Check your email for a link to the one-time contact form.')

    click_link_or_button 'Back to previous page'
    assert_equal main_url, current_url
  end

  # Regression: the request is created in the registry database and reaches ours with replication
  # delay. When it did not arrive within MAX_SYNC_WAIT_TIME the user was told that the registry was
  # unreachable, although the request had been created and the link was on its way.
  def test_sends_confirmation_even_when_the_record_is_not_replicated_yet
    not_replicated = @valid_contact_request.attributes.merge('id' => 999_999)
    stub_request(:post, 'http://registry:3000/api/v1/contact_requests/')
      .to_return(status: 200, body: not_replicated.to_json, headers: {})

    visit new_contact_request_path(params: { domain_name: 'privatedomain.test' })

    fill_in('contact_request[email]', with: @valid_contact_request.email)
    fill_in('contact_request[name]', with: 'Test User')
    click_link_or_button 'Get a link'

    assert_text('Check your email for a link to the one-time contact form.')
  end

  def test_redirects_to_main_path_when_no_registry_connection
    stub_error = stub_request(:post, 'http://registry:3000/api/v1/contact_requests/').to_return(status: 400, headers: {})

    visit new_contact_request_path(params: { domain_name: 'privatedomain.test' })

    fill_in('contact_request[email]', with: @valid_contact_request.email)
    fill_in('contact_request[name]', with: 'Test User1')
    click_link_or_button 'Get a link'

    assert_text('Domain registry connect error. Please, try again later')
    remove_request_stub(stub_error)
  end
end
