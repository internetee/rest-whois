require 'test_helper'

class ContactRequestMailerTest < ActionMailer::TestCase
  def test_determines_if_ses_configured
    assert_not ApplicationMailer.ses_configured?

    Aws.config.update(
      region: 'us-east-2',
      credentials: Aws::Credentials.new('123', '123'),
      stub_responses: {
        send_email: { message_id: 'TESTING' }}
    )

    assert ApplicationMailer.ses_configured?

    Aws.config.update(
      region: nil,
      credentials: nil,
      stub_responses: false
    )
  end
end
