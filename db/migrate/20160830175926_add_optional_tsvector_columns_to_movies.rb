class AddOptionalTsvectorColumnsToMovies < ActiveRecord::Migration
  def up
    add_column :movies, :tsv_optional, :tsvector
    add_index :movies, :tsv_optional, using: "gin"

    execute <<-SQL
      CREATE TRIGGER opttsvectorupdate BEFORE INSERT OR UPDATE
      ON movies FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv_optional, 'pg_catalog.english', fr_title, original_title, title
      );
    SQL

    now = Time.current.to_s(:db)
    update("UPDATE movies SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER opttsvectorupdate
      ON movies
    SQL

    remove_index :movies, :tsv_optional
    remove_column :movies, :tsv_optional
  end
end
