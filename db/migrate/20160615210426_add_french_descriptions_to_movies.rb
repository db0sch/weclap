class AddFrenchDescriptionsToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :fr_title, :string
    add_column :movies, :fr_tagline, :string
    add_column :movies, :fr_overview, :string
  end
end
