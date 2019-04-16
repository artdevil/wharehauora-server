# frozen_string_literal: true

class Api::Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  before_action :not_allowed, only: [:new, :edit, :cancel]

  clear_respond_to
  respond_to :json
  
  def not_allowed
    raise MethodNotAllowed
  end

  def create
    super do |resource|
      resource.skip_confirmation!
    end
  end

  private
    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end