json.success true
json.key @key
json.home do
  json.id @home.id
  json.name @home.name
end

json.room do
  json.id @room.id
  json.name @room.name
end

json.data @data
