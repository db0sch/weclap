class AddTsvectorColumnsToMovies < ActiveRecord::Migration
  def up
    add_column :movies, :tsv, :tsvector
    add_index :movies, :tsv, using: "gin"

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON movies FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'pg_catalog.english', fr_title, original_title, title
      );
    SQL

    now = Time.current.to_s(:db)
    update("UPDATE movies SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER tsvectorupdate
      ON movies
    SQL

    remove_index :movies, :tsv
    remove_column :movies, :tsv
  end
end
