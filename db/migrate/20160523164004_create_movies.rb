class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :title
      t.string :original_title
      t.date :released_fr
      t.integer :runtime
      t.string :tagline
      t.text :summary
      t.string :genre
      t.integer :parental_rating
      t.text :credits
      t.string :poster_url
      t.string :trailer_url
      t.string :website_url
      t.string :imdb_id
      t.integer :imdb_score
      t.string :cnc_url
      t.integer :tmdb_id

      t.timestamps null: false
    end
  end
end
