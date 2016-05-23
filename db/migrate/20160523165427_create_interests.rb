class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.timestamp :watched_on
      t.references :user, index: true, foreign_key: true
      t.references :movie, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
