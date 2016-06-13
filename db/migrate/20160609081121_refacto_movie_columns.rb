class RefactoMovieColumns < ActiveRecord::Migration
  def change
    remove_column :movies, :poster_path, :string
    remove_column :movies, :budget, :integer
    remove_column :movies, :production_countries, :text
    add_column :movies, :collection, :json

    reversible do |dir|
      dir.up do
        add_column :movies, :setup, :boolean, default: false
        Movie.unscoped.where.not(tmdb_id: nil).update_all(setup: true)
        rename_column :movies, :adult, :s_adult
        add_column :movies, :adult, :boolean, default: false
        Movie.unscoped.where(s_adult: 't').update_all(adult: true)
        remove_column :movies, :s_adult
      end

      dir.down do
        remove_column :movies, :setup, :boolean, default: false
        rename_column :movies, :adult, :b_adult
        add_column :movies, :adult, :string, default: 'f'
        Movie.unscoped.where(b_adult: true).update_all(adult: 't')
        remove_column :movies, :b_adult
      end
    end
  end
end
