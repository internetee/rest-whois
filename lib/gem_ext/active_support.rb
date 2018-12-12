# Needed for special format - 2010-07-05T10:30:00+00:00

module ActiveSupport
  class TimeWithZone
    def as_json(_options = nil)
      if ActiveSupport::JSON::Encoding.use_standard_json_time_format
        strftime('%Y-%m-%dT%H:%M:%S%:z')
      else
        %(#{time.strftime('%Y/%m/%d %H:%M:%S')} #{formatted_offset(false)})
      end
    end
  end
end
