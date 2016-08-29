class AddIndexToMovies < ActiveRecord::Migration
  def change
    add_index :movies, [:fr_title, :original_title, :title]
  end
end
