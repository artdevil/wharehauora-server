json.success true
json.data do
  json.id @room.id
  json.name @room.name

  if @room.room_type.present?
    json.room_type do
      json.id @room.room_type.id
      json.name @room.room_type.name
    end
  else
    json.room_type nil
  end

  json.temperature do
    json.value display_temperature(@room)
    json.last_update reading_age_in_words(@room, 'temperature')
    json.status temperature_reading(@room)
  end

  json.humidity do
    json.value display_humidity(@room)
    json.last_update reading_age_in_words(@room, 'humidity')
    json.status humidity_reading(@room)
  end

  json.dewpoint do
    json.value display_dewpoint(@room)
    json.last_update reading_age_in_words(@room, 'dewpoint')
    json.status dewpoint_reading(@room)
  end

  json.rating do
    json.grade @room.rating
    json.value rating_text(@room)
    json.status room_grade_class(@room)
  end

  json.array_analysis @room.array_analysis

  json.sensors @room.sensors do |sensor|
    json.id sensor.id
    json.name sensor.name
    json.battery_level 'Not supported'

    if sensor.home.gateway.present?
      json.software sensor.home.gateway.version
    else
      json.software 'unknown'
    end

    json.last_reading sensor_last_message(sensor)
    json.first_detected sensor_first_detected(sensor)
  end
end
