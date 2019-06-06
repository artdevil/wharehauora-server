json.success true
json.data @homes do |home|
  json.id home.id
  json.name home.name

  if home.home_type.present?
    json.home_type do
      json.id home.home_type.id
      json.name home.home_type.name
    end
  else
    json.home_type nil
  end

  json.rooms home.rooms_count
  json.sensors home.sensors_count
end
