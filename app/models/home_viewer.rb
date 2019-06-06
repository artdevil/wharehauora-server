# frozen_string_literal: true

# == Schema Information
#
# Table name: home_viewers
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  home_id    :integer
#  user_id    :integer
#
# Indexes
#
#  index_home_viewers_on_user_id_and_home_id  (user_id,home_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (user_id => users.id)
#

class HomeViewer < ApplicationRecord
  attr_accessor :email

  belongs_to :user
  belongs_to :home

  validates :user, presence: true, uniqueness: { scope: [:home_id], message: 'already assign as home viewer' }
  validates :home, presence: true

  def assigned_user_to_home
    user_assigned = User.find_by(email: email) || User.invite!(email: email)

    if user_assigned.errors.present?
      errors.add(:email, user_assigned.errors.full_messages)
      false
    else
      self.user = user_assigned
      self.home = home
      save
    end
  end
end
