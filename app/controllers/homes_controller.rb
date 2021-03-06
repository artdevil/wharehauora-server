# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :set_home, only: %i[show edit destroy update]
  respond_to :html

  def index
    authorize :home
    @homes = policy_scope(Home)
             .includes(:home_type, :owner)
             .order(:name)
             .paginate(page: params[:page])
    respond_with(@homes)
  end

  def show
    redirect_to home_rooms_path(@home)
  end

  def new
    @home = Home.new
    authorize @home
    respond_with(@home)
  end

  def create
    authorize :home
    @home = Home.new(home_params)
    invite_new_owner
    if @home.save
      respond_with(@home, location: home_rooms_path(@home))
    else
      respond_with(@home)
    end
  end

  def edit
    @home_types = HomeType.all
    respond_with(@home)
  end

  def update
    @home.update(home_params)
    respond_with(@home)
  end

  def destroy
    @home.destroy
    respond_with(@home)
  end

  private

  def invite_new_owner
    if current_user.janitor?
      owner = User.find_by(owner_params)
      @home.owner = owner || User.invite!(owner_params)
    else
      @home.owner = current_user
    end
  end

  def parse_dates
    @day = params[:day]
    @day = Time.zone.today if @day.blank?
  end

  def home_params
    params.require(:home).permit(
      :name, :address, :latitude, :longitude, :house_age, :city, :suburb, :is_public,
      :home_type_id, :gateway_mac_address, :residents_with_respiratory_illness, :residents_with_allergies,
      :residents_with_depression, :residents_with_anxiety, :residents_with_lgbtq, :residents_with_physical_disabled,
      :residents_with_children, :residents_with_elderly,
      residents_ethnics: []
    )
  end

  def owner_params
    params.require('owner').permit('email')
  end

  def set_home
    @home = policy_scope(Home).find(params[:id])
    authorize @home
  end
end
