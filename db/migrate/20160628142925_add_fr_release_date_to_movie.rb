class AddFrReleaseDateToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :fr_release_date, :date
  end
end
