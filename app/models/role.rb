# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  friendly_name :string           not null
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_roles_on_name  (name) UNIQUE
#


class Role < ApplicationRecord
  has_many :user_roles
  has_many :users, through: :user_roles

  validates :name, :friendly_name, presence: true
end
