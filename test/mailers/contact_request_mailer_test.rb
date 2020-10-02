require 'test_helper'

class ContactRequestMailerTest < ActionMailer::TestCase
  def setup
    @contact_request = contact_requests(:valid)
  end

  def test_confirmation_email
    I18n.locale = I18n.default_locale
    email = ContactRequestMailer
            .confirmation_email(@contact_request)
            .deliver_now

    refute(ActionMailer::Base.deliveries.empty?)
    assert_equal(['no-reply@internet.ee'], email.from)
    assert_equal(['email@example.com'], email.to)
    assert_equal('Email address confirmation', email.subject)
    assert_equal(read_fixture('confirmation_email.erb').join, email.body.to_s.gsub(/\r/, ""))
  end

  def test_confirmation_email_can_be_localized
    I18n.locale = :et
    email = ContactRequestMailer
            .confirmation_email(@contact_request)
            .deliver_now

    refute(ActionMailer::Base.deliveries.empty?)
    assert_equal(['no-reply@internet.ee'], email.from)
    assert_equal(['email@example.com'], email.to)
    assert_equal('E-posti aadressi kinnituskiri', email.subject)
    assert_equal(read_fixture('localized_confirmation_email.erb').join,
                 email.body.to_s.gsub(/\r/, ""))

    I18n.locale = I18n.default_locale
  end

  def test_contact_request_email
    body = begin
      "Hi!\n" \
      "\n" \
      "I have an amazing business opportunity. Please contact me at my_email@test.com.\n" \
      "\n" \
      "Best regards,\n" \
      'John Smith'
    end
    email = ContactRequestMailer.contact_email(
      contact_request: @contact_request,
      recipients: ['admin@privatedomain.com', 'owner@private_domain.com'],
      mail_body: body
    ).deliver_now

    refute(ActionMailer::Base.deliveries.empty?)
    assert_equal(['no-reply@internet.ee'], email.from)
    assert_equal(['admin@privatedomain.com', 'owner@private_domain.com'], email.to)
    assert_equal(['email@example.com'], email.reply_to)
    assert_equal('Email to domain owner and/or contact', email.subject)
    assert_equal(read_fixture('contact_request_email.erb').join,
                 email.body.to_s.gsub(/\r/, ""))
  end

  def test_contact_request_email_strips_html_tags_from_body
    body = begin
      "<p>Hello <a href='https://malicious-link.com'>there</a></p>"
    end
    email = ContactRequestMailer.contact_email(
      contact_request: @contact_request,
      recipients: ['admin@privatedomain.com', 'owner@private_domain.com'],
      mail_body: body
    ).deliver_now

    refute(ActionMailer::Base.deliveries.empty?)
    assert_equal(['no-reply@internet.ee'], email.from)
    assert_equal(['admin@privatedomain.com', 'owner@private_domain.com'], email.to)
    assert_equal(['email@example.com'], email.reply_to)
    assert_equal('Email to domain owner and/or contact', email.subject)
    assert_equal(read_fixture('stripped_contact_request_email.erb').join,
                 email.body.to_s.gsub(/\r/, ""))
  end

  def test_character_limit_constants_defaults_to_2000
    assert_equal(2000, ContactRequestMailer::CHARACTER_LIMIT)
  end

  def test_contact_request_email_cuts_off_message_at_2000_characters
    body = <<-TEXT.squish
    Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.
    Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus
    mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa
    quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo,
    rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium.
    Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend
    tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem
    ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius
    laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper
    ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus,
    sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Lo
    Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor.
    Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus
    mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa
    quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo,
    rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium.
    Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend
    tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem
    ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius
    laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper
    ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus,
    sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Lo

    >--- This line should be skipped ----<
    TEXT

    email = ContactRequestMailer.contact_email(
      contact_request: @contact_request,
      recipients: ['admin@privatedomain.com', 'owner@private_domain.com'],
      mail_body: body
    ).deliver_now

    refute_match('This line should be skipped', email.body.to_s.rstrip)
  end

  def test_attempts_to_send_contact_email_via_aws_ses
    mail_body = begin
      "Hi!\n" \
      "\n" \
      "I have an amazing business opportunity. Please contact me at my_email@test.com.\n" \
      "\n" \
      "Best regards,\n" \
      'John Smith'
    end

    Aws.config.update(
      region: 'us-east-2',
      credentials: Aws::Credentials.new('123', '123'),
      stub_responses: {
        send_email: { message_id: 'TESTING' }}
    )

    ApplicationMailer.stub(:ses_configured?, true) do
      ContactRequestMailer.contact_email(
        contact_request: @contact_request,
        recipients: ['admin@privatedomain.com', 'owner@private_domain.com'],
        mail_body: mail_body
      ).deliver_now
    end

    assert_equal 'TESTING', @contact_request.message_id

    Aws.config.update(
      region: nil,
      credentials: nil,
      stub_responses: false
    )
  end
end
