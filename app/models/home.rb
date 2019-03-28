# == Schema Information
#
# Table name: homes
#
#  id                                  :integer          not null, primary key
#  address                             :text
#  city                                :string
#  gateway_mac_address                 :string
#  house_age                           :string
#  is_public                           :boolean          default(FALSE), not null
#  latitude                            :string
#  longitude                           :string
#  name                                :text             not null
#  own_house_type                      :string
#  residents_ethnics                   :string           default([]), is an Array
#  residents_with_allergies            :boolean          default(FALSE), not null
#  residents_with_children             :boolean          default(FALSE), not null
#  residents_with_elderly              :boolean          default(FALSE), not null
#  residents_with_lgbtq                :boolean          default(FALSE), not null
#  residents_with_mental_health_issues :boolean          default(FALSE), not null
#  residents_with_physical_disabled    :boolean          default(FALSE), not null
#  residents_with_respiratory_illness  :boolean          default(FALSE), not null
#  rooms_count                         :integer
#  sensors_count                       :integer
#  suburb                              :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  home_type_id                        :integer
#  owner_id                            :integer          not null
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
  serialize :address, EncryptedCoder.new
  serialize :latitude, EncryptedCoder.new
  serialize :longitude, EncryptedCoder.new

  OWNER_HOUSE_TYPE_LIST = ['own your home', 'rent privately', 'rent from Housing NZ'].freeze
  RESIDENTS_ETHNICS_LIST = [
    'Māori', 'Pacific peoples', 'Middle Eastern', 'Latin American', 'African', 'Asian', 'European'
  ].freeze

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

  def selected_other_own_house_type?
    !Home::OWNER_HOUSE_TYPE_LIST.include?(own_house_type)
  end

  def selected_other_residents_ethnics?
    !Home::RESIDENTS_ETHNICS_LIST.include?(residents_ethnics)
  end

  def other_residents_ethnics
    (residents_ethnics - Home::RESIDENTS_ETHNICS_LIST).first
  end

  private

  def fix_gateway_address
    return if gateway_mac_address.blank?

    self.gateway_mac_address = gateway_mac_address.gsub(/\s/, '').delete(':').upcase
  end
end
