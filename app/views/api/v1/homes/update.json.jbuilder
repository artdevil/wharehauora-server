json.success true
json.data do
  json.id @home.id
  json.name @home.name
  json.address @home.address
  json.latitude @home.latitude
  json.longitude @home.longitude
  json.house_age @home.house_age
  json.city @home.city
  json.suburb @home.suburb
  json.gateway_mac_address @home.gateway_mac_address
  json.residents_with_respiratory_illness @home.residents_with_respiratory_illness
  json.residents_with_allergies @home.residents_with_allergies
  json.residents_with_depression @home.residents_with_depression
  json.residents_with_anxiety @home.residents_with_anxiety
  json.residents_with_lgbtq @home.residents_with_lgbtq
  json.residents_with_physical_disabled @home.residents_with_physical_disabled
  json.residents_with_children @home.residents_with_children
  json.residents_with_elderly @home.residents_with_elderly
  json.residents_ethnics @home.residents_ethnics
  json.home_type_id @home.home_type_id
end
