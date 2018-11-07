require 'test_helper'

class WHOISRecordHTMLPrivatelyOwnedTest < ActionDispatch::IntegrationTest
  include CaptchaHelpers

  setup do
    @whois_record = whois_records(:privately_owned)

    @original_whitelist_ip = ENV['whitelist_ip']
    ENV['whitelist_ip'] = ''

    enable_captcha
  end

  teardown do
    ENV['whitelist_ip'] = @original_whitelist_ip
  end

  def test_optional_attributes
    ENV['whitelist_ip'] = '127.0.0.1'
    @whois_record.update!(json: { name: 'shop.test',
                                  status: %w[any],
                                  registered: nil,
                                  changed: nil,
                                  expire: nil,
                                  outzone: nil,
                                  delete: nil,
                                  registrant_changed: nil,
                                  registrar_changed: nil,
                                  nameservers: ['test'],
                                  nameservers_changed: nil,
                                  dnssec_keys: ['test'],
                                  dnssec_changed: nil,
                                  admin_contacts: [{ changed: nil }],
                                  tech_contacts: [{ changed: nil }] })

    visit '/v1/privatedomain.test'

    assert_text(
      <<-TEXT.squish
        Domain:
        name:       shop.test
        status:     any
        registered: 
        changed:    
        expire:     
        outzone:    
        delete:

        Registrant:
        name:       
        email:      
        changed:

        Administrative contact:
        name:       
        email:      
        changed:

        Technical contact:
        name:       
        email:      
        changed:

        Registrar:
        name:       
        url:        
        phone:      
        changed:

        Name servers:
        nserver:   test
        changed:   

        DNSSEC:
        dnskey:   test
        changed:
      TEXT
    )
  end
end
