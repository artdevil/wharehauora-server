# frozen_string_literal: true

class Api::Users::RegistrationsController < Api::BaseController
  skip_before_action :doorkeeper_authorize!, only: [:create]
  respond_to :json

  def create
    user = User.new(user_params)

    if user.save
      user.skip_confirmation!
      
      access_token = Doorkeeper::AccessToken.create!(
        application_id: nil, 
        resource_owner_id: user.id,
        use_refresh_token: true,
        expires_in: Doorkeeper.configuration.access_token_expires_in.to_i
      )

      render json: Doorkeeper::OAuth::TokenResponse.new(access_token).body.to_json
    else
      respond_form_with_error(user.errors, user_params)
    end
  end

  def update
    @user = current_user
    if @user.update_with_password(user_change_password_params)
      respond_with(@user)
    else
      respond_form_with_error(@user.errors, user_change_password_params)
    end
  end

  private

  def user_change_password_params
    params.permit(:current_password, :password, :password_confirmation)
  end

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end
