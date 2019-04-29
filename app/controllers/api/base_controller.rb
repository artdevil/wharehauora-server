# frozen_string_literal: true

class Api::BaseController < JSONAPI::ResourceController
  force_ssl if Rails.env.production?
  include Pundit::ResourceController
  before_action :doorkeeper_authorize!

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_user
    current_resource_owner
  end
end
