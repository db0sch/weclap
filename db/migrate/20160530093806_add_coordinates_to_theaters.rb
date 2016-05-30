class AddCoordinatesToTheaters < ActiveRecord::Migration
  def change
    add_column :theaters, :latitude, :float
    add_column :theaters, :longitude, :float
  end
end
