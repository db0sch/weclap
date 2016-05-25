class AddNameToTheaters < ActiveRecord::Migration
  def change
    add_column :theaters, :name, :string
  end
end
