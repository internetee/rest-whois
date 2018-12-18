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
end
