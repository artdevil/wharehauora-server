# frozen_string_literal: true

# == Schema Information
#
# Table name: room_types
#
#  id              :integer          not null, primary key
#  max_temperature :float
#  min_temperature :float
#  name            :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#


class RoomType < ApplicationRecord
  validates :name, uniqueness: true, presence: true
  has_many :rooms
end
