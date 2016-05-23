class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.timestamp :starts_at
      t.references :movie, index: true, foreign_key: true
      t.references :theater, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
