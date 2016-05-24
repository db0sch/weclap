class CreateStreamings < ActiveRecord::Migration
  def change
    create_table :streamings do |t|
      t.string :consumption
      t.string :link
      t.integer :price
      t.references :movie, index: true, foreign_key: true
      t.references :provider, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
