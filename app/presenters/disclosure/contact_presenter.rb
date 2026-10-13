module Disclosure
  # Admin/tech contact fields under the Domain Regulation 2027 policy.
  # A contact's attributes are only revealed before the privileged level
  # when the contact itself volunteered them (contact_publishable == true
  # AND attr in disclosed_attributes); nothing is derived from the
  # registrant's type.
  class ContactPresenter < BasePresenter
    def initialize(contact_json, level)
      super(level)
      @contact = contact_json || {}
    end

    def name
      attribute('name')
    end

    def email
      attribute('email')
    end

    def phone
      attribute('phone')
    end

    def last_update
      gated(@contact['changed'], :privileged)
    end

    def identification
      privileged? ? @contact.slice('kind', 'reg_no', 'ident_country_code') : {}
    end

    private

    def attribute(attr)
      return @contact[attr] if privileged? || volunteered?(attr)
      return @contact[attr] if org_details_at_detailed? && level_at_least?(:detailed)

      org_details_at_detailed? ? disclosable_mask : undisclosable_mask
    end

    # Only tech contacts disclose their org attributes at the detailed
    # level; admin contacts never do.
    def org_details_at_detailed?
      false
    end

    def volunteered?(attr)
      @contact['contact_publishable'] == true &&
        (@contact['disclosed_attributes'] || []).include?(attr)
    end
  end
end
