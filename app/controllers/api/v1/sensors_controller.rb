# frozen_string_literal: true

class Api::V1::SensorsController < Api::BaseController
  before_action :set_sensor, only: %i[update unassign]
  before_action :set_home, only: %i[index]
  respond_to :json

  def index
    @sensors = @home.sensors.filters_by(filter_params).paginate(page: params[:page])
  end

  def update
    room = if sensor_params_contains_room?
             Room.create(room_params.merge(home_id: @home.id))
           else
             policy_scope(Room).find_by_id_and_home_id(sensor_params[:room_id], @home.id)
           end

    if @sensor.update_attributes(room: room)
      respond_with(@sensor)
    else
      respond_form_with_error(@sensor.errors, params)
    end
  end

  def unassign
    @room = @sensor.room
    @room&.unassign_sensor(@sensor)
  end

  private

  def set_home
    @home = @sensor ? @sensor.home : policy_scope(Home).find(params[:home_id])
    authorize @home
  end

  def set_sensor
    @sensor = policy_scope(Sensor).where(home_id: params[:home_id]).find(params[:id])
    authorize @sensor
    @home = @sensor.home
  end

  def sensor_params
    params.permit(:room_id)
  end

  def filter_params
    params.permit(:assigned)
  end

  def sensor_params_contains_room?
    params[:room].present? and params[:room][:name].present?
  end

  def room_params
    params.require(:room).permit(:name)
  end
end
