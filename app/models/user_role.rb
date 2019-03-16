# frozen_string_literal: true

# == Schema Information
#
# Table name: user_roles
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  role_id    :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_user_roles_on_role_id  (role_id)
#  index_user_roles_on_user_id  (user_id)
#

class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  validates :user, presence: true
  validates :role, presence: true
end
