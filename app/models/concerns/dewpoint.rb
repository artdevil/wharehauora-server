# frozen_string_literal: true

module Dewpoint
  extend ActiveSupport::Concern

  included do
    def below_dewpoint?
      Rails.cache.fetch("#{cache_key}/below_dewpoint?", expires_in: 10.minutes) do
        return false if temperature.nil? || dewpoint.nil?

        temperature < dewpoint
      end
    end

    def near_dewpoint?
      Rails.cache.fetch("#{cache_key}/near_dewpoint?", expires_in: 10.minutes) do
        return false if temperature.nil? || dewpoint.nil?

        (temperature - 2) < dewpoint
      end
    end

    def calculate_dewpoint
      temp_c = single_current_metric 'temperature'
      humidity = single_current_metric 'humidity'
      return unless temp_c && humidity

      l = Math.log(humidity / 100.0)
      m = 17.27 * temp_c
      n = 237.3 + temp_c
      b = (l + (m / n)) / 17.27
      (237.3 * b) / (1 - b)
    end
  end
end
