require 'test_helper'

class RegistryConnectorTest < ActiveSupport::TestCase
  def test_do_update_addresses_the_endpoint_of_a_single_record
    stub = stub_request(:put, 'http://registry:3000/api/v1/contact_requests/42')
           .to_return(status: 200, body: '{"id":42}', headers: {})

    assert_equal({ 'id' => 42 },
                 RegistryConnector.do_update(id: 42, data: { status: 'confirmed' }))
    assert_requested(stub)
  end

  def test_do_update_returns_false_when_the_registry_answers_with_an_error
    stub_request(:put, %r{contact_requests/42}).to_return(status: 502, body: '', headers: {})

    refute(RegistryConnector.do_update(id: 42, data: { status: 'confirmed' }))
  end

  # An unreachable registry used to escape as an exception and hit the user with a 500 page.
  def test_do_save_returns_false_when_the_registry_cannot_be_reached
    stub_request(:post, 'http://registry:3000/api/v1/contact_requests/').to_timeout

    refute(RegistryConnector.do_save(email: 'someone@example.test'))
  end
end
