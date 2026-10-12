# Activation switch for the new .ee WHOIS disclosure policy
# (https://github.com/internetee/registry/issues/2969).
#
# The activation timestamp is parsed once at boot from
# ENV['DISCLOSURE_POLICY_ACTIVE_FROM'] (see
# config/initializers/disclosure_policy.rb). It must be an ISO 8601
# timestamp with an explicit offset, e.g. "2027-01-18T00:00:00+02:00".
# Unset or blank keeps the legacy behaviour; a malformed value aborts
# boot so a policy is never picked silently.
class DisclosurePolicy
  ENV_KEY = 'DISCLOSURE_POLICY_ACTIVE_FROM'

  # A timezone designator at the end of the timestamp: "Z" or "+02:00".
  OFFSET_PATTERN = /([zZ]|[+-](?:[01]\d|2[0-3]):?[0-5]\d)\z/

  class << self
    attr_accessor :active_from

    def active?(now = Time.current)
      !active_from.nil? && now >= active_from
    end

    def load_from_env
      self.active_from = parse(ENV[ENV_KEY])
    end

    def parse(raw)
      return if raw.blank?

      raise_malformed(raw) unless OFFSET_PATTERN.match?(raw)

      begin
        # Time.iso8601 normalizes invalid calendar dates; DateTime rejects them.
        DateTime.iso8601(raw)
        Time.iso8601(raw)
      rescue ArgumentError
        raise_malformed(raw)
      end
    end

    private

    def raise_malformed(raw)
      raise ArgumentError,
            "#{ENV_KEY} must be an ISO 8601 timestamp with an explicit offset " \
            "(e.g. '2027-01-18T00:00:00+02:00'), got: #{raw.inspect}"
    end
  end
end
