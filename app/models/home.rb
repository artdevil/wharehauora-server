# == Schema Information
#
# Table name: homes
#
#  id                                 :integer          not null, primary key
#  address                            :text
#  city                               :string
#  gateway_mac_address                :string
#  house_age                          :string
#  is_public                          :boolean          default(FALSE), not null
#  latitude                           :string
#  longitude                          :string
#  name                               :text             not null
#  residents_ethnics                  :string           default([]), is an Array
#  residents_with_allergies           :boolean          default(FALSE), not null
#  residents_with_anxiety             :boolean          default(FALSE), not null
#  residents_with_children            :boolean          default(FALSE), not null
#  residents_with_depression          :boolean          default(FALSE), not null
#  residents_with_elderly             :boolean          default(FALSE), not null
#  residents_with_lgbtq               :boolean          default(FALSE), not null
#  residents_with_physical_disabled   :boolean          default(FALSE), not null
#  residents_with_respiratory_illness :boolean          default(FALSE), not null
#  rooms_count                        :integer
#  sensors_count                      :integer
#  suburb                             :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  home_type_id                       :integer
#  owner_id                           :integer          not null
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

  accepts_nested_attributes_for :home_viewers, reject_if: proc { |f| f['user_id'].blank? }, allow_destroy: true

  scope(:is_public?, -> { where(is_public: true) })

  validates :name, presence: true
  validates :owner, presence: true
  before_validation :fix_gateway_address
  validates :gateway_mac_address,
            presence: true,
            format: { with: /\A[A-F0-9]*\z/, message: 'should have only letters A-F and numbers' }

  ##
  # old function we don't used it anymore but keep this code in case
  # old home need doing provision
  def provision_mqtt!
    ActiveRecord::Base.transaction do
      mu = MqttUser.where(home: self).first_or_initialize
      mu.provision!
      mu.save!
    end
  end

  def gateway
    Gateway.find_by(mac_address: gateway_mac_address)
  end

  def selected_other_residents_ethnics?
    other_residents_ethnics.present?
  end

  def other_residents_ethnics
    (residents_ethnics - Home::RESIDENTS_ETHNICS_LIST).first
  end

  def self.form_options(options = [])
    data = {
      home_type: HomeType.select(:id, :name)
    }

    if options.present?
      data.delete(:home_type) unless options[:home_type].present? and options[:home_type].to_bool
    end
    
    return data
  end

  private

  def fix_gateway_address
    return if gateway_mac_address.blank?

    self.gateway_mac_address = gateway_mac_address.gsub(/\s/, '').delete(':').upcase
  end
end
