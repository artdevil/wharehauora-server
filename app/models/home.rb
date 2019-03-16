# frozen_string_literal: true

# == Schema Information
#
# Table name: homes
#
#  id                  :integer          not null, primary key
#  gateway_mac_address :string
#  is_public           :boolean          default(FALSE), not null
#  name                :text             not null
#  rooms_count         :integer
#  sensors_count       :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  home_type_id        :integer
#  owner_id            :integer          not null
#
# Indexes
#
#  index_homes_on_is_public  (is_public)
#  index_homes_on_name       (name)
#  index_homes_on_owner_id   (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (home_type_id => home_types.id)
#  fk_rails_...  (owner_id => users.id)
#


class Home < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  belongs_to :home_type, optional: true

  has_one :mqtt_user

  has_many :rooms
  has_many :messages, through: :sensors

  has_many :sensors
  has_many :readings, through: :rooms

  has_many :home_viewers

  has_many :users, through: :home_viewers

  has_many :invitations

  scope(:is_public?, -> { where(is_public: true) })

  validates :name, presence: true
  validates :owner, presence: true
  before_validation :fix_gateway_address
  validates :gateway_mac_address, uniqueness: true,
                                  allow_blank: true,
                                  format: { with: /\A[A-F0-9]*\z/, message: 'should have only letters A-F and numbers' }

  def provision_mqtt!
    return if gateway_mac_address.blank?

    ActiveRecord::Base.transaction do
      mu = MqttUser.where(home: self).first_or_initialize
      mu.provision!
      mu.save!
    end
  end

  def gateway
    Gateway.find_by(mac_address: gateway_mac_address)
  end

  private

  def fix_gateway_address
    return if gateway_mac_address.blank?

    self.gateway_mac_address = gateway_mac_address.gsub(/\s/, '').delete(':').upcase
  end
end
