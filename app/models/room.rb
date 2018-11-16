# frozen_string_literal: true

class Room < ApplicationRecord
  belongs_to :home, counter_cache: true
  belongs_to :room_type, optional: true

  has_many :readings
  has_many :sensors

  has_one :home_type, through: :home
  has_one :owner, through: :home

  validates :home, presence: true
  validates :name, presence: true

  scope(:with_no_readings, -> { includes(:readings).where(readings: { id: nil }) })
  scope(:with_no_sensors, -> { includes(:sensors).where(sensors: { id: nil }) })

  scope(:has_readings, -> { includes(:sensors).where.not(sensors: { id: nil }) })

  include Measurable
  include Dewpoint
  include Rateable

  def public?
    home.is_public
  end

  def sensor?
    sensors.size.positive?
  end

  def assign_sensor(sensor)
    sensors << sensor
  end

  def unassign_sensor(sensor)
    sensors.delete(sensor)
  end

  def current?(key)
    age = age_of_last_reading(key)
    age.present? && age < 2.hours
  end

  def age_of_last_reading(key)
    Rails.cache.fetch("#{cache_key}/age_of_last_readings", expires_in: 10.minutes) do
      return unless readings.where(key: key).size.positive?

      Time.current - last_reading_timestamp(key)
    end
  end

  def most_recent_reading(key)
    Reading.where(room_id: id, key: key)&.last
  end

  def last_reading_timestamp(key)
    readings.where(key: key)
            .order(created_at: :desc)
            .limit(1)
            .first&.created_at
  end
end
