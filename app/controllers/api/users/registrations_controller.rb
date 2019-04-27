# frozen_string_literal: true

class Api::Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  before_action :not_allowed, only: %i[new edit cancel]

  clear_respond_to
  respond_to :json

  def new
  end

  def edit
  end

  def cancel
  end

  def not_allowed
    raise MethodNotAllowed
  end

  def create
    super(&:skip_confirmation!)
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
