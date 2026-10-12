module Disclosure
  # Registrant fields under the Domain Regulation 2027 policy.
  #
  # - org registrant: name/email/reg_no/ident_country are revealed at the
  #   detailed level; phone is revealed at detailed only when it matches the
  #   business registry (`phone` in registrant_system_disclosed_attributes)
  # - private registrant: nothing beyond volunteered attributes
  # - a volunteered attribute (publishable == true AND attr in
  #   registrant_disclosed_attributes) is visible at every level; for the
  #   phone a system-disclosed entry does not count as volunteering
  class RegistrantPresenter < BasePresenter
    def initialize(whois_json, level)
      super(level)
      @json = whois_json
    end

    def org?
      @json['registrant_kind'] == 'org'
    end

    def type
      org? ? 'org' : 'priv'
    end

    def name
      gated_registrant_attribute('registrant', 'name')
    end

    def email
      gated_registrant_attribute('email', 'email')
    end

    def phone
      return @json['phone'] if privileged? || volunteered?('phone')

      if org?
        return @json['phone'] if level_at_least?(:detailed) && system_disclosed_phone?

        system_disclosed_phone? ? disclosable_mask : undisclosable_mask
      else
        undisclosable_mask
      end
    end

    def reg_number
      gated_org_attribute('registrant_reg_no')
    end

    def ident_country
      gated_org_attribute('registrant_ident_country_code')
    end

    def last_update
      gated(@json['registrant_changed'], :privileged)
    end

    private

    # Attributes an org registrant reveals at the detailed level.
    def gated_registrant_attribute(key, attr)
      return @json[key] if privileged? || volunteered?(attr)
      return @json[key] if org? && level_at_least?(:detailed)

      org? ? disclosable_mask : undisclosable_mask
    end

    # Attributes that are only meaningful for an org registrant.
    def gated_org_attribute(key)
      return @json[key] if privileged?
      return @json[key] if org? && level_at_least?(:detailed)

      org? ? disclosable_mask : undisclosable_mask
    end

    def volunteered?(attr)
      return false unless @json['registrant_publishable'] == true
      return false if attr == 'phone' && system_disclosed_phone?

      disclosed_attributes.include?(attr)
    end

    def disclosed_attributes
      @json['registrant_disclosed_attributes'] || []
    end

    def system_disclosed_phone?
      (@json['registrant_system_disclosed_attributes'] || []).include?('phone')
    end
  end
end
