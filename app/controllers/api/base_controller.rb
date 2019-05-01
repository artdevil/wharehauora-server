# frozen_string_literal: true

class Api::BaseController < ActionController::Base
  include Pundit
  force_ssl if Rails.env.production?
  before_action :doorkeeper_authorize!
  
  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_user
    current_resource_owner
  end

  def respond_form_with_error(errors, params = {})
    data = {}
    data[:success] = false
    data[:params] = params if params.present?
    data[:errors] = errors if errors.present?

    render :json => data, status: 422
  end
end
