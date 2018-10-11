module Measurable
  extend ActiveSupport::Concern

  included do
    def temperature
      single_current_metric 'temperature'
    end

    def humidity
      single_current_metric 'humidity'
    end

    def dewpoint
      single_current_metric 'dewpoint'
    end

    def mould
      single_current_metric 'mould'
    end

    def single_current_metric(key)
      most_recent_reading(key)&.value
    end
  end
end
