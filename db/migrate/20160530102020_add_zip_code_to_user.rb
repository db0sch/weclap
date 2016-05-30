class AddZipCodeToUser < ActiveRecord::Migration
  def change
    add_column :users, :zip_code, :string, default: "75001"
    add_column :users, :city, :string, default: "Paris"
  end
end
