# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id             :integer          not null, primary key
#  name           :text
#  readings_count :integer
#  sensors_count  :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  home_id        :integer          not null
#  room_type_id   :integer
#
# Indexes
#
#  index_rooms_on_home_id  (home_id)
#  index_rooms_on_name     (name)
#
# Foreign Keys
#
#  fk_rails_...  (room_type_id => room_types.id)
#

class Room < ApplicationRecord
  belongs_to :home, counter_cache: true
  belongs_to :room_type, optional: true

  has_many :readings, dependent: :destroy
  has_many :sensors

  has_one :home_type, through: :home
  has_one :owner, through: :home

  validates :home, presence: true
  validates :name, presence: true

  scope(:with_no_readings, -> { includes(:readings).where(readings: { id: nil }) })
  scope(:with_no_sensors, -> { includes(:sensors).where(sensors: { id: nil }) })
  scope(:with_sensors, -> { includes(:sensors).where.not(sensors: { id: nil }) })

  scope(:has_readings, -> { includes(:sensors).where.not(sensors: { id: nil }) })

  before_destroy :checking_existing_sensors

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

  def analysis
    return 'Edit room type to get analysis' if room_type.blank?
    return 'offline' if !enough_info_to_perform_rating?

    if comfortable?
      'Comfortable temperature.'
    elsif too_hot?
      'Too hot.'
    elsif too_cold?
      "Too cold for a #{room_type.name.downcase}"
    elsif good?
      'Room is good.'
    end
  end

  def array_analysis
    data = []
    data.push('Very cold room') if way_too_cold?
    data.push('Temperature below recommended levels') if too_cold?
    data.push('Comfortable') if comfortable?
    data += ['Comfortable humidity', 'Acceptable dewpoint', 'Temp is well above dewpoint'] if dry?
    if below_dewpoint?
      data += [
        'Risk for cold, damp, and mould',
        "When the temperature in this room falls below #{ApplicationController.helpers.display_dewpoint(self)} "\
        'moisture begins to form on surfaces, leading to mould growth.'
      ]
    end
    data
  end

  class << self
    def form_options(options = [])
      data = { room_type: RoomType.select(:id, :name) }

      if options.present?
        data.delete(:room_type) unless options[:room_type].present? && options[:room_type].to_bool
      end

      data
    end

    def filters_by(filters)
      data = where(false)

      if filters[:with_sensors].present?
        data = filters[:with_sensors].to_bool ? data.with_sensors : data.with_no_sensors
      end

      data
    end
  end

  private

  def checking_existing_sensors
    return if sensors.blank?

    errors.add(:base, 'Please unasigned sensor before deleting it')
    throw(:abort)
  end
end
