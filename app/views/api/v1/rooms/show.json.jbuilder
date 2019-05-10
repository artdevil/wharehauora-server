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

  json.temprature do
    json.read display_temperature(@room)
    json.last_update reading_age_in_words(@room, 'temperature')
  end

  json.humidity do
    json.read display_humidity(@room)
    json.last_update reading_age_in_words(@room, 'temperature')
  end

  json.dewpoint do
    json.read display_dewpoint(@room)
    json.last_update reading_age_in_words(@room, 'dewpoint')
  end

  json.rating do
    json.grade @room.rating
    json.read rating_text(@room)
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