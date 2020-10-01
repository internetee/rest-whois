require 'test_helper'

class BounceBackTest < ActionDispatch::IntegrationTest

  def setup
    @domain = whois_records(:privately_owned)
    @contact_request = contact_requests(:valid)
    @contact_request.update(message_id: '123')
  end

  def test_consumes_aws_sns_verification_url
    confirm_url = "https://confirmurl.test/"
    aws_payload = aws_verification_payload

    stub_request(:any, confirm_url)

    # Request to #bounce inititates request to aws to verify webhook
    post aws_sns_bounce_path, params: aws_payload.to_json
    assert_response :success
    assert_requested :get, confirm_url, times: 1
  end

  def test_attempts_to_send_bounce_alert_for_bounced_mail
    aws_payload = aws_bounce_notification
    # stub_request(:any, "www.example.com")
    # AWS webhook to #bounce for bounced emails
    post aws_sns_bounce_path, params: aws_payload.to_json
    assert_response :success
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [@contact_request.email], ActionMailer::Base.deliveries.last.to
  end

  def test_sends_bounce_alert_to_registry_api
    registry_bounce_url = 'http://registry.test/bounce'

    # Stub Bounces logging API path
    ENV["bounces_api_url"] = registry_bounce_url
    stub_request(:post, registry_bounce_url)

    aws_payload = aws_bounce_notification
    post aws_sns_bounce_path, params: aws_payload.to_json

    assert_requested :post, registry_bounce_url, times: 1

    ENV["bounces_api_url"] = ''
  end

  def aws_verification_payload
    { "Type"=>"SubscriptionConfirmation",
      "MessageId"=>"123",
      "Token"=>"123",
      "TopicArn"=>"rest-whois-bounces",
      "Message"=>"You have chosen to subscribe to the topic rest-whois-bounces.",
      "SubscribeURL"=> "https://confirmurl.test/",
      "Timestamp"=>"2020-09-15T07:37:46.064Z"
    }
  end

  def aws_bounce_notification
    { "notificationType"=>"Bounce",
      "bounce"=>{
        "feedbackId"=>"010f017490c9677b-4dabfd93-8b2e-4ffb-9f57-eeeb41889d5e-000000",
        "bounceType"=>"Permanent",
        "bounceSubType"=>"General",
        "bouncedRecipients"=>[
          {"emailAddress"=> @domain.json['email'], "action"=>"failed", "status"=>"5.1.1", "diagnosticCode"=>"smtp; 550 5.1.1 user unknown"}
        ],
        "timestamp"=>"2020-09-15T08:02:32.490Z",
        "remoteMtaIp"=>"100.24.160.226",
        "reportingMTA"=>"dsn; xxx.amazonses.com"
      },
      "mail"=>{
        "timestamp"=>"2020-09-15T08:02:32.000Z",
        "source"=> ENV['mailer_from_address'],
        "sourceArn"=>"arn:aws:ses:us-east-2:123:identity/#{ENV['mailer_from_address']}",
        "sourceIp"=>"127.0.0.1", "sendingAccountId"=>"123",
        "messageId"=>"#{@contact_request.message_id}",
        "destination"=>[
          @domain.json['email'],
          @domain.json['admin_contacts'][0]['email']
        ]
      }
    }
  end
end