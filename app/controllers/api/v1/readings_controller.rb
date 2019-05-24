# frozen_string_literal: true

class Api::V1::ReadingsController < Api::BaseController
  before_action :set_room
  respond_to :json

  def index
    @key = params[:key]
    @data = assemble_readings
    respond_with(@data)
  end

  private

  def set_room
    @room = policy_scope(Room).find(params[:room_id])
    authorize @room, :show?
    @home = @room.home
  end

  def assemble_readings
    data_by_room = []
    readings.each do |reading|
      created_at, reading_value = reading
      data_by_room << { created_at => reading_value.round(2) }
    end

    data_by_room
  end

  def readings
    Rails.cache.fetch("#{@room.id}/#{@key}/readings", expires_in: 5.minutes) do
      Reading
        .joins(:room)
        .where(key: @key, room: @room)
        .order('readings.created_at')
        .limit(1000)
        .pluck("date_trunc('minute', readings.created_at)", :value)
    end
  end
end
