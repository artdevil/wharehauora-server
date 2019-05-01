# frozen_string_literal: true

class Api::V1::HomesController < Api::BaseController
  before_action :set_home, only: %i[show edit destroy update]
  respond_to :json

  def index
    authorize :home
    @homes = policy_scope(Home).paginate(page: params[:page])
  end

  def create
    authorize :home
    @home = Home.new(home_params)
    @home.owner = current_user

    if @home.save
      respond_with(@home)
    else
      respond_form_with_error(@home.errors, home_params)
    end
  end

  def update
    if @home.update_attributes(home_params)
      respond_with(@home)
    else
      respond_form_with_error(@home.errors, home_params)
    end
  end

  def destroy
    if @home.destroy
      respond_with(@home)
    else
      respond_form_with_error(@home.errors)
    end
  end

  private

  def home_params
    params.permit(
      :name, :address, :latitude, :longitude, :house_age, :city, :suburb,
      :gateway_mac_address, :residents_with_respiratory_illness, :residents_with_allergies,
      :residents_with_depression, :residents_with_anxiety, :residents_with_lgbtq, :residents_with_physical_disabled,
      :residents_with_children, :residents_with_elderly,
      residents_ethnics: []
    )
  end

  def set_home
    @home = policy_scope(Home).find(params[:id])
    authorize @home
  end
end
