json.success true
json.data do
  json.id @sensor.id
  json.name @sensor.name
  if @sensor.room.present?
    json.room do
      json.id @sensor.room.id
      json.name @sensor.room.name
    end
  else
    json.room nil
  end
end
