# frozen_string_literal: true

class Api::Users::PasswordsController < Api::BaseController
  skip_before_action :doorkeeper_authorize!, only: [:create]
  respond_to :json

  def create
    @user = User.send_reset_password_instructions(user_params)

    if @user.errors.empty?
      respond_with(@user)
    else
      respond_form_with_error(@user.errors, user_params)
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

  def user_params
    params.permit(:email)
  end
end
