# frozen_string_literal: true

# == Schema Information
#
# Table name: sensors
#
#  id             :integer          not null, primary key
#  mac_address    :string
#  messages_count :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  home_id        :integer          not null
#  node_id        :integer          not null
#  room_id        :integer
#
# Indexes
#
#  index_sensors_on_node_id  (node_id)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (room_id => rooms.id)
#

class Sensor < ApplicationRecord
  before_create :create_room
  belongs_to :home, counter_cache: true
  validates :home, presence: true
  validate :same_home_as_room
  validates :mac_address, uniqueness: { scope: :home_id }

  belongs_to :room, counter_cache: true, optional: true

  has_many :messages, dependent: :destroy

  delegate :home_type, to: :home
  delegate :room_type, to: :room

  scope(:joins_home, -> { joins(:room, room: :home) })
  scope(:with_no_messages, -> { includes(:messages).where(messages: { id: nil }) })

  def last_message
    messages.order(created_at: :desc).first&.created_at
  end

  def same_home_as_room
    return true if room_id.blank?

    room.home_id == home_id
  end

  private

  def create_room
    self.room = Room.create!(name: '{mac_address}{node_id}', home: home) if room_id.blank?
  end
end
