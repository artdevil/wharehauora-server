# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  invited_by_type        :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :integer
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  validates :email, presence: true
  validate :no_deleted_account_exists

  has_many :user_roles
  has_many :roles, through: :user_roles

  has_one :mqtt_user

  has_many :home_viewers, dependent: :destroy
  has_many :viewable_homes, class_name: 'Home', source: :home, through: :home_viewers
  has_many :owned_homes, class_name: 'Home', foreign_key: :owner_id

  acts_as_paranoid # soft deletes, sets deleted_at column

  def no_deleted_account_exists
    return unless User.only_deleted.where(email: email).size.positive?

    errors.add(:email, 'already exists as a deleted account')
  end

  def homes
    owned_homes + viewable_homes
  end

  def role?(role)
    roles.any? { |r| r.name == role }
  end

  def janitor?
    role? 'janitor'
  end
end
