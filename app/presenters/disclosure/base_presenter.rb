module Disclosure
  # Shared level handling for the Domain Regulation 2027 disclosure
  # presenters. `level` is one of :public, :detailed or :privileged and is
  # resolved once per request by WhoisRecordsController.
  class BasePresenter
    LEVELS = %i[public detailed privileged].freeze

    attr_reader :level

    def initialize(level)
      @level = level
    end

    private

    def privileged?
      level == :privileged
    end

    def level_at_least?(min_level)
      LEVELS.index(level) >= LEVELS.index(min_level)
    end

    def disclosable_mask
      I18n.t('masks.disclosable')
    end

    def undisclosable_mask
      I18n.t('masks.undisclosable')
    end

    # Value is hidden below `min_level`; the mask says whether solving the
    # captcha (detailed level) would reveal it.
    def gated(value, min_level)
      return value if level_at_least?(min_level)

      min_level == :detailed ? disclosable_mask : undisclosable_mask
    end
  end
end
