json.success true
json.data @viewers do |viewer|
  json.id viewer.id
  json.user_email viewer.user.email
end
