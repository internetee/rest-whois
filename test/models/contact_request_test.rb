require 'test_helper'

class ContactRequestTest < ActiveJob::TestCase
  self.use_transactional_tests = true

  def setup
    super

    @whois_record = whois_records(:privately_owned)
    @contact_request = ContactRequest.create(
      whois_record: @whois_record,
      email: 'contact-me-here@email.com',
      name: 'Test User'
    )

    stub_request(:put, /http:\/\/registry:3000\/api\/v1\/contact_requests\/\d+/).to_return(status: 200, body: @contact_request.to_json, headers: {})
    stub_request(:post, "http://registry:3000/api/v1/contact_requests/").to_return(status: 200, body: @contact_request.to_json, headers: {})
  end

  def teardown
    super

    ActionMailer::Base.deliveries.clear
  end

  def test_new_request_needs_required_fields
    contact_request = ContactRequest.new
    refute(contact_request.valid?)

    contact_request = ContactRequest.new(whois_record: @whois_record)
    refute(contact_request.valid?)

    contact_request = ContactRequest.new(whois_record: @whois_record,
                                         email: 'contact-me-here@email.com')
    refute(contact_request.valid?)

    contact_request = ContactRequest.new(whois_record: @whois_record,
                                         email: 'contact-me-here@email.com',
                                         name: 'Test User')
    assert(contact_request.valid?)
  end

  def test_new_request_has_default_status_new
    contact_request = ContactRequest.new
    assert_equal('new', contact_request.status)
  end

  def test_new_request_generates_random_124_character_secret_on_creation
    @contact_request.save
    assert_equal(128, @contact_request.secret.length)
  end

  def test_secret_cannot_be_changed
    @contact_request.save
    @contact_request.update!(secret: 'foo')
    @contact_request.reload

    refute_equal('foo', @contact_request.secret)
  end

  def test_valid_to_cannot_be_changed
    @contact_request.save
    new_date = Time.parse('2018-01-01 00:00 UTC')
    @contact_request.update!(valid_to: new_date)
    @contact_request.reload

    refute_equal(new_date, @contact_request.valid_to)
  end

  def test_can_be_confirmed_only_once
    assert(@contact_request.confirm_email)

    @contact_request.update(status: 'confirmed')
    refute(@contact_request.confirm_email)
  end

  def test_mark_as_sent
    @contact_request.confirm_email
    @contact_request.update(status: 'confirmed')

    assert(@contact_request.mark_as_sent)
  end

  def test_completed_or_expired_during_lifecycle
    refute(@contact_request.completed_or_expired?)

    @contact_request.confirm_email
    refute(@contact_request.completed_or_expired?)
    @contact_request.update(status: 'confirmed')

    @contact_request.mark_as_sent
    @contact_request.update(status: 'sent')

    assert(@contact_request.completed_or_expired?)
  end

  def test_completed_or_expired_when_contact_request_is_old
    expired_request = contact_requests(:expired)
    assert(expired_request.completed_or_expired?)
  end

  def test_send_contact_email_makes_emails_unique
    whois_record_with_dupe_emails = whois_records(:with_duplicate_domain_contacts)
    not_unique_contact_request = ContactRequest.create(
      whois_record: whois_record_with_dupe_emails,
      email: 'contact-me-here@email.com',
      name: 'Test User'
    )
    not_unique_contact_request.save

    stub_request(:put, "http://registry:3000/contact_requests/#{not_unique_contact_request.id}").to_return(status: 200, body: "", headers: {})

    not_unique_contact_request.confirm_email

    body = 'some message text'
    recipients = %w[admin_contacts tech_contacts]
    not_unique_contact_request.update(status: 'confirmed')
    not_unique_contact_request.send_contact_email(body: body, recipients: recipients)
    mail = ActionMailer::Base.deliveries.last
    assert_equal(['duplicate@domain.test'], mail.to)
  end

  def test_send_contact_email_updates_status_and_calls_mailer
    @contact_request.confirm_email
    @contact_request.update(status: 'confirmed')

    body = 'some message text'
    recipients = %w[admin_contacts]

    @contact_request.send_contact_email(body: body, recipients: recipients)
    @contact_request.update(status: 'sent')
    assert(@contact_request.completed_or_expired?)

    mail = ActionMailer::Base.deliveries.last
    assert_equal(['no-reply@internet.ee'], mail.from)
    assert_equal(['owner@privatedomain.test', 'admin-contact@privatedomain.test'], mail.to)
    assert_equal(['contact-me-here@email.com'], mail.reply_to)
    assert_equal('Email to domain owner and/or contact', mail.subject)
    assert_match('some message text', mail.body.to_s)
  end

  def test_send_contact_email_many_times_if_error
    @contact_request.confirm_email
    @contact_request.update(status: 'confirmed')

    body = 'some message text'
    recipients = %w[admin_contacts]
    contacts = @contact_request.send(:extract_emails_for_recipients, recipients)

    assert_difference 'ActionMailer::Base.deliveries.count', contacts.count do
      perform_enqueued_jobs do
        @contact_request.send_contact_email(body: body, recipients: recipients, raise_error: true)
      end
    end

    assert_equal ActionMailer::Base.deliveries.map(&:to).flatten, contacts
  end

  def test_send_contact_email_only_to_tech_contact
    @contact_request.confirm_email
    @contact_request.update(status: 'confirmed')

    body = 'some message text'
    recipients = %w[tech_contacts]

    @contact_request.send_contact_email(body: body, recipients: recipients)
    @contact_request.update(status: 'sent')
    assert(@contact_request.completed_or_expired?)

    mail = ActionMailer::Base.deliveries.last
    assert_equal(['tech-contact@privatedomain.test'], mail.to)
  end

  def test_send_contact_email_does_nothing_when_not_sendable
    @contact_request.save
    refute(@contact_request.send_contact_email)
  end

  def test_send_contact_email_does_nothing_when_recipients_are_empty
    @contact_request.confirm_email
    @contact_request.update(status: 'confirmed')

    assert_equal(ContactRequest::STATUS_CONFIRMED, @contact_request.status)
    refute(@contact_request.send_contact_email)
  end

  def test_removing_whois_record_does_not_remove_contact_requests
    @contact_request.save
    @whois_record.delete

    refute(@contact_request.whois_record.persisted?)
  end

  def test_completed_or_expired_returns_false_when_whois_record_is_deleted
    @contact_request.save
    @whois_record.delete
    @contact_request.reload

    assert(@contact_request.completed_or_expired?)
  end

  def test_registrant_bounced_returns_valid_outcome
    registrant_email = @contact_request.whois_record.json['email']

    admin_tech_contacts = [
      {"emailAddress": @contact_request.whois_record.json['admin_contacts'][0]['email']},
      {"emailAddress": @contact_request.whois_record.json['tech_contacts'][0]['email']}
    ]

    assert_not @contact_request.registrant_bounced? [].as_json
    assert_not @contact_request.registrant_bounced? [{"emailAddress": "registrant.test"}].as_json
    assert_not @contact_request.registrant_bounced? [{"emailAddress": @contact_request.whois_record.json['admin_contacts'][0]['email']}].as_json
    assert_not @contact_request.registrant_bounced? admin_tech_contacts.as_json
    all_addr = admin_tech_contacts << { "emailAddress": registrant_email}

    assert @contact_request.registrant_bounced?(all_addr.as_json)
  end

  def test_sends_bounce_email_if_registrant_not_bounced
    @contact_request.update(message_id: 1234)
    json = verified_aws_bounce_notification.as_json

    ContactRequest.send_bounce_alert(json)
    assert_not ActionMailer::Base.deliveries.empty?
  end

  def test_does_not_send_bounce_email_if_registrant_not_bounced
    @contact_request.update(message_id: 1234)
    json = verified_aws_bounce_notification.as_json
    json['bounce']['bouncedRecipients'][0]['emailAddress'] = 'random@definitelynotvalid.test'

    ContactRequest.send_bounce_alert(json)
    assert ActionMailer::Base.deliveries.empty?
  end

  def verified_aws_bounce_notification
    { "notificationType"=>"Bounce",
      "bounce"=>{
        "feedbackId"=>"010f017490c9677b-4dabfd93-8b2e-4ffb-9f57-eeeb41889d5e-000000",
        "bounceType"=>"Permanent",
        "bounceSubType"=>"General",
        "bouncedRecipients"=>[
          {"emailAddress"=> @whois_record.json['email'], "action"=>"failed", "status"=>"5.1.1", "diagnosticCode"=>"smtp; 550 5.1.1 user unknown"}
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
          @whois_record.json['email'],
          @whois_record.json['admin_contacts'][0]['email']
        ]
      }
    }
  end
end
