module Disclosure
  class RegistrarPresenter < BasePresenter
    def initialize(whois_json, level)
      super(level)
      @json = whois_json
    end

    def name
      @json['registrar']
    end

    def website
      @json['registrar_website']
    end

    def phone
      @json['registrar_phone']
    end

    def email
      @json['registrar_email']
    end

    def address
      @json['registrar_address']
    end

    def last_update
      gated(@json['registrar_changed'], :privileged)
    end
  end
end
