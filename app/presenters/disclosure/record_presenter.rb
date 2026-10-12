# The nested presenter names collide with the top-level legacy presenters
# (RegistrantPresenter, ContactPresenter). Under the classic autoloader a
# top-level constant wins the lookup inside `module Disclosure`, so the
# nested files must be required explicitly.
require_dependency 'disclosure/base_presenter'
require_dependency 'disclosure/contact_presenter'
require_dependency 'disclosure/domain_presenter'
require_dependency 'disclosure/registrant_presenter'
require_dependency 'disclosure/registrar_presenter'
require_dependency 'disclosure/tech_contact_presenter'

module Disclosure
  # Entry point of the Domain Regulation 2027 presentation pipeline: wraps a
  # WhoisRecord and exposes level-gated field values for both the HTML and
  # the JSON rendering.
  class RecordPresenter < BasePresenter
    attr_reader :whois_record

    def initialize(whois_record, level)
      super(level)
      @whois_record = whois_record
    end

    def domain
      DomainPresenter.new(whois_record.domain, level)
    end

    def registrant
      RegistrantPresenter.new(json, level)
    end

    def registrar
      RegistrarPresenter.new(json, level)
    end

    def admin_contacts
      contacts('admin_contacts').map { |contact| ContactPresenter.new(contact, level) }
    end

    def tech_contacts
      contacts('tech_contacts').map { |contact| TechContactPresenter.new(contact, level) }
    end

    def nameserver_records
      records = json['nameserver_records']

      return fallback_nameserver_records if records.blank?

      records.map do |record|
        { 'hostname' => record['hostname'],
          'ipv4' => record['ipv4'] || [],
          'ipv6' => record['ipv6'] || [] }
      end
    end

    def nameservers_changed
      gated(json['nameservers_changed'], :privileged)
    end

    def dnssec_keys
      json['dnssec_keys']
    end

    def dnssec_changed
      gated(json['dnssec_changed'], :privileged)
    end

    private

    def json
      whois_record.json || {}
    end

    def contacts(kind)
      json[kind] || []
    end

    # Blobs generated before `nameserver_records` existed carry only the
    # hostnames in `nameservers`.
    def fallback_nameserver_records
      (json['nameservers'] || []).map do |hostname|
        { 'hostname' => hostname, 'ipv4' => [], 'ipv6' => [] }
      end
    end
  end
end
