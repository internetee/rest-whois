module Disclosure
  class DomainPresenter < BasePresenter
    attr_reader :domain

    delegate :name, :statuses, :active?, :registered, :expire,
             :registration_deadline, to: :domain

    def initialize(domain, level)
      super(level)
      @domain = domain
    end

    def changed
      gated(domain.changed, :detailed)
    end

    def outzone
      gated(domain.outzone, :detailed)
    end

    def delete
      gated(domain.delete, :detailed)
    end
  end
end
