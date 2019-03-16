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
  belongs_to :user
  belongs_to :home

  validates :user, presence: true
  validates :home, presence: true
end
