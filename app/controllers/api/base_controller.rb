# frozen_string_literal: true

class Api::BaseController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  include Pundit
  force_ssl if Rails.env.production?
  before_action :doorkeeper_authorize!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

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

    render json: data, status: 422
  end

  def respond_empty_data_with_error(model_class, error_type)
    data = {}
    data[:success] = false
    data[:errors] = "can't find #{model_class}" if error_type == ActiveRecord::RecordNotFound

    render json: data, status: 404
  end

  def user_not_authorized
    data = {}
    data[:success] = false
    data[:error] = 'You are not authorized to perform this action'
    render json: data, status: 401
  end

  def not_found
    data = {}
    data[:success] = false
    data[:error] = 'Data not found'
    render json: data, status: 404
  end
end
