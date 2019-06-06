# frozen_string_literal: true

class Api::V1::HomesController < Api::BaseController
  before_action :set_home, only: %i[show destroy update]
  respond_to :json

  def show; end

  def index
    authorize :home
    @homes = policy_scope(Home).includes(:home_type).paginate(page: params[:page])
  end

  def form_options
    authorize :home
    @home_form_options = Home.form_options(home_options_params)
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
      :name, :address, :latitude, :longitude, :house_age, :city, :suburb, :home_type_id,
      :gateway_mac_address, :residents_with_respiratory_illness, :residents_with_allergies,
      :residents_with_depression, :residents_with_anxiety, :residents_with_lgbtq, :residents_with_physical_disabled,
      :residents_with_children, :residents_with_elderly,
      residents_ethnics: []
    )
  end

  def home_options_params
    params.permit(:home_type)
  end

  def set_home
    @home = policy_scope(Home).find(params[:id])
    authorize @home
  end
end
