# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  ack             :integer
#  message_type    :string
#  payload         :text
#  sub_type        :integer
#  topic           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  child_sensor_id :integer
#  node_id         :integer
#  sensor_id       :integer
#
# Indexes
#
#  index_messages_on_created_at  (created_at)
#  index_messages_on_sensor_id   (sensor_id)
#
# Foreign Keys
#
#  fk_rails_...  (sensor_id => sensors.id)
#


class Message < ApplicationRecord
  belongs_to :sensor, counter_cache: true
  delegate :home, :home_id, to: :sensor

  validates :node_id, :sensor_id, :child_sensor_id,
            :message_type, :ack, :sub_type, presence: true

  after_create :save_reading, :save_dewpoint

  scope(:joins_home, -> { joins(:sensor, sensor: :home) })

  def decode(topic, payload)
    self.topic = topic
    self.payload = payload
    if version == 'v2'
      decode_v2
    else
      decode_v1
    end
    self
  end

  def version
    topic.split('/')[2]
  end

  private

  def decode_v1
    (home_id, node_id, child_sensor_id, message_type, ack, sub_type) = topic.split('/')[3..-1]
    update!(
      sensor: Sensor.find_or_create_by!(home_id: home_id, node_id: node_id),
      node_id: node_id,
      child_sensor_id: child_sensor_id,
      message_type: message_type,
      ack: ack,
      sub_type: sub_type,
      payload: payload
    )
  end

  def decode_v2
    (gateway_mac_address, sensor_mac, child_sensor_id, message_type, ack, sub_type) = topic.split('/')[3..-1]
    home = Home.find_by!(gateway_mac_address: gateway_mac_address)
    sensor = Sensor.find_or_create_by!(home: home, mac_address: sensor_mac, node_id: sensor_mac)

    update!(
      sensor: sensor,
      node_id: sensor_mac,
      child_sensor_id: child_sensor_id,
      message_type: message_type,
      ack: ack,
      sub_type: sub_type,
      payload: payload
    )
  end

  def save_reading
    Reading.create!(room: sensor.room, value: payload.to_f, key: key) if sensor.room_id.present?
  end

  def save_dewpoint
    return unless sensor.room && key == 'temperature'

    dewpoint = sensor.room.calculate_dewpoint
    return if dewpoint.nil?

    Reading.create!(room: sensor.room,
                    value: dewpoint,
                    key: 'dewpoint')
  end

  def key
    case child_sensor_id.to_i
    when 0
      'humidity'
    when 1
      'temperature'
    else
      'unknown'
    end
  end
end
