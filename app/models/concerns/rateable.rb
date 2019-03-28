# frozen_string_literal: true

module Rateable
  extend ActiveSupport::Concern

  included do
    def rating
      Rails.cache.fetch("#{cache_key}/rating", expires_in: 10.minutes) do
        return '?' unless enough_info_to_perform_rating?
        number = 100
        if too_cold?
          number -= 20
        elsif way_too_cold?
          number -= 40
        elsif below_dewpoint?
          number -= 40
        end
        RoomService.rating_letter(number)
      end
    end

    def dry?
      Rails.cache.fetch("#{cache_key}/dry?", expires_in: 10.minutes) do
        !below_dewpoint? && !near_dewpoint?
      end
    end

    def good?
      Rails.cache.fetch("#{cache_key}/good?", expires_in: 10.minutes) do
        return false if !enough_info_to_perform_rating? || below_dewpoint? || too_cold? || too_hot?
        true
      end
    end

    def too_cold?
      Rails.cache.fetch("#{cache_key}/too_cold?", expires_in: 10.minutes) do
        (temperature < room_type.min_temperature) if enough_info_to_perform_rating?
      end
    end

    def way_too_cold?
      Rails.cache.fetch("#{cache_key}/way_too_cold?", expires_in: 10.minutes) do
        (temperature < (room_type.min_temperature - 5)) if enough_info_to_perform_rating?
      end
    end

    def too_hot?
      Rails.cache.fetch("#{cache_key}/too_hot?", expires_in: 10.minutes) do
        (temperature > room_type.max_temperature) if enough_info_to_perform_rating?
      end
    end

    def comfortable?
      Rails.cache.fetch("#{cache_key}/comfortable?", expires_in: 10.minutes) do
        !too_hot? && !too_cold?
      end
    end

    def enough_info_to_perform_rating?
      room_type && current?('temperature') && room_type.min_temperature.present? && room_type.max_temperature.present?
    end
  end
end
