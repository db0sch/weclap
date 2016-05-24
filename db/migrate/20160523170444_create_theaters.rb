class CreateTheaters < ActiveRecord::Migration
  def change
    create_table :theaters do |t|
      t.string :address

      t.timestamps null: false
    end
  end
end
