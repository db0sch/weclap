class ChangeImdbScoreType < ActiveRecord::Migration
  def change
        remove_column :movies, :imdb_score, :integer
        add_column :movies, :imdb_score, :float
  end
end
