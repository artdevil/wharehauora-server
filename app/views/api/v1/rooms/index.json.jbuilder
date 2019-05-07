json.success true
json.data @rooms do |room|
  json.id room.id
  json.name room.name
  
  if room.room_type.present?
    json.room_type do
      json.id room.room_type.id
      json.name room.room_type.name
    end
  else
    json.room_type nil
  end

  json.temprature do
    json.read display_temperature(room)
    json.last_update reading_age_in_words(room, 'temperature')
  end

  json.humidity do
    json.read display_humidity(room)
    json.last_update reading_age_in_words(room, 'temperature')
  end

  json.analysis room.analysis
end