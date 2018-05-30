require 'test_helper'

class ContactRequestsConfirmationTest < ActionDispatch::IntegrationTest
  def setup
    super

    @private_domain = whois_records(:privately_owned)
    @valid_contact_request = contact_requests(:valid)
    @expired_contact_request = contact_requests(:expired)
  end

  def teardown
    super
  end

  def test_link_from_whois_record_page
    visit("v1/privatedomain.test")
    click_link_or_button("Contact owner")

    assert(find_field('contact_request[email]'))
    assert(find_field('contact_request[name]'))
    text = begin
      'You will receive an one time link to confirm your email, and then send a message to the owner or administrator ' \
      "of the domain.\n" \
      'The link expires in 24 hours.'
    end

    assert_text(text)
  end

  def test_new_request_fails_if_there_is_no_domain_name_passed
    assert_raise ActiveRecord::RecordNotFound do
      visit(new_contact_request_path)
    end
  end

  def test_link_from_whois_record_page_does_not_exists_for_discarded_domains
    visit("v1/discarded-domain.test")
    refute(has_link?('Contact owner'))
  end

  def test_new_request_fails_if_that_is_a_discarded_domain
    visit(new_contact_request_path(params: { domain_name: 'discarded-domain.test' }))
    assert_equal(403, page.status_code)
    assert(page.body.empty?)
  end

  def test_link_from_whois_record_page_does_not_exists_for_legal_owners
    visit("v1/company-domain.test")
    refute(has_link?('Contact owner'))
  end

  def test_new_request_fails_if_that_is_not_a_private_domain
    visit(new_contact_request_path(params: { domain_name: 'company-domain.test' }))
    assert_equal(403, page.status_code)
    assert(page.body.empty?)
  end

  def test_expired_contact_request_returns_403_with_empty_body
    visit(contact_request_path(@expired_contact_request.secret))
    assert_equal(403, page.status_code)
    assert(page.body.empty?)
  end

  def test_create_a_email_confirmation_delivery
    visit(new_contact_request_path(params: { domain_name: 'privatedomain.test' }))
    fill_in('contact_request[email]', with: 'i-want-to-contact-you@domain.com')
    fill_in('contact_request[name]', with: 'Test User')
    click_link_or_button 'Get a link'

    assert_text('Contact request created. Check your email for a link to the one-time contact form.')

    mail = ActionMailer::Base.deliveries.last
    assert_equal(['no-reply@internet.ee'], mail.from)
    assert_equal(['i-want-to-contact-you@domain.com'], mail.to)
    assert_equal('E-posti aadressi kinnituskiri / Email address confirmation / Запрос данных владельца домена', mail.subject)

    friendly_mail_body = mail.body.to_s
    expected_body = 'Please click the link below to confirm your email address and access the contact form.'
    expected_link = 'example.test/contact_request'
    expected_disclaimer = 'Link expires in 24 hours.'

    assert_match(expected_body,       friendly_mail_body)
    assert_match(expected_link,       friendly_mail_body)
    assert_match(expected_disclaimer, friendly_mail_body)
  end

  # Locale tests start here
  def test_en_locale_in_confirmation_form
    visit(new_contact_request_path(params: { domain_name: 'privatedomain.test' }))
    text = begin
      'You will receive an one time link to confirm your email, and then send a message to the owner or administrator ' \
      "of the domain.\n" \
      'The link expires in 24 hours.'
    end

    assert(has_link?(href: 'https://www.internet.ee/domains/eif-s-data-protection-policy'))
    assert_text(text)
  end

  def test_et_locale_in_confirmation_form
    visit(new_contact_request_path(params: { domain_name: 'privatedomain.test', locale: 'et' }))
    text = <<-TEXT.squish
    Saadame Teie sisestatud e-posti aadressile kinnituskirja, mis sisaldab ühekordset unikaalset
    linki. Link suunab teid kirja vormile, kust saate oma teate saata valitud .ee domeeni
    kontaktidele (domeeni omanik, haldus- ja tehniline kontakt).
    TEXT
    assert(has_link?(href: 'https://www.internet.ee/domeenid/eis-i-isikuandmete-kasutamise-alused'))
    assert_text(text)
  end

  def test_ru_locale_in_confirmation_form
    visit(new_contact_request_path(params: { domain_name: 'privatedomain.test', locale: 'ru' }))
    assert_text t('contact_requests.instructions', locale: :ru)
    # TODO: Fix the link when correct
    assert(has_link?(href: 'https://www.internet.ee/domains/eif-s-data-protection-policy'))
  end
end
