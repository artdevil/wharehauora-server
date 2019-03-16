# frozen_string_literal: true

# == Schema Information
#
# Table name: gateways
#
#  id          :integer          not null, primary key
#  mac_address :text
#  version     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#


class Gateway < ApplicationRecord
end
