# frozen_string_literal: true

class Api::V1::RoomsController < Api::BaseController
  before_action :set_room, only: %i[show edit destroy update]
  before_action :set_home, only: %i[index edit update]

  respond_to :json

  def index
    @rooms = @home.rooms.includes(:room_type).order(:name).paginate(page: params[:page])
  end

  def show
    skip_authorization if @room.public?
    @readings = Reading.where(room: @room).order(created_at: :desc).limit(10)
    respond_with(@room)
  end

  def edit
    respond_with(@room)
  end

  def update
    if @room.update_attributes(room_params)
      respond_with(@room)
    else
      respond_form_with_error(@room.errors, room_params)
    end
  end

  def destroy
    if @room.destroy
      respond_with(@room)
    else
      respond_form_with_error(@room.errors, room_params)
    end
  end

  def form_options
    authorize :home
    @room_form_options = Room.form_options(room_options_params)
  end

  private

  def set_home
    @home = @room ? @room.home : policy_scope(Home).find(params[:home_id])
    authorize @home
  end

  def set_room
    @room = policy_scope(Room).find(params[:id])
    authorize @room
    @home = @room.home
  end

  def room_params
    params.permit(permitted_room_params)
  end

  def permitted_room_params
    %i[name room_type_id]
  end

  def room_options_params
    params.permit(:room_type)
  end
end
