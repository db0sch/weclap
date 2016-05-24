
class ChangeFieldsToMovies < ActiveRecord::Migration
  def change
    remove_column :movies, :parental_rating, :genre, :imdb_score
    remove_column :movies, :summary, :poster_url, :released_fr


    add_column :movies, :adult, :string
    add_column :movies, :budget, :integer
    add_column :movies, :genres, :string
    add_column :movies, :overview, :text
    add_column :movies, :popularity, :float
    add_column :movies, :original_language, :string
    add_column :movies, :poster_path, :string
    add_column :movies, :production_countries, :text
    add_column :movies, :release_date, :string
    add_column :movies, :spoken_languages, :text
  end
end
