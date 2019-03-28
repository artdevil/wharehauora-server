# frozen_string_literal: true

# == Schema Information
#
# Table name: home_types
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class HomeType < ApplicationRecord
  validates :name, uniqueness: true, presence: true
  has_many :homes
end
