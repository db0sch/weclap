class ChangeCreditsTypeInMovies < ActiveRecord::Migration
  def up
    change_column :movies, :credits, 'json USING CAST(credits AS json)'
    change_column :movies, :genres, 'json USING CAST(genres AS json)'
    # and remove unused column genre
    remove_column :movies, :genre
  end

  def down
    change_column :movies, :credits, 'text USING CAST(credits AS text)'
    change_column :movies, :genres, 'text USING CAST(genres AS text)'
    add_column :movies, :genre, :string
  end
end
