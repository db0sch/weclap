class AddRatingToInterests < ActiveRecord::Migration
  def change
    add_column :interests, :rating, :integer
  end
end
