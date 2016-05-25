class ChangeDateTypeToReleaseDate < ActiveRecord::Migration
  def change
    remove_column :movies, :release_date
    remove_column :movies, :released_fr


    add_column :movies, :release_date, :date
  end
end
