class AddExtraInfoForHome < ActiveRecord::Migration[5.1]
  def change
    add_column :homes, :address, :text
    add_column :homes, :latitude, :string
    add_column :homes, :longitude, :string
    add_column :homes, :city, :string
    add_column :homes, :suburb, :string
    add_column :homes, :house_age, :string
    add_column :homes, :own_house_type, :string
    add_column :homes, :residents_ethnics, :string, array: true, default: []
    add_column :homes, :residents_with_lgbtq, :boolean, null: false, default: false
    add_column :homes, :residents_with_physical_disabled, :boolean, null: false, default: false
    add_column :homes, :residents_with_respiratory_illness, :boolean, null: false, default: false
    add_column :homes, :residents_with_allergies, :boolean, null: false, default: false
    add_column :homes, :residents_with_mental_health_issues, :boolean, null: false, default: false
    add_column :homes, :residents_with_children, :boolean, null: false, default: false
    add_column :homes, :residents_with_elderly, :boolean, null: false, default: false
  end
end
