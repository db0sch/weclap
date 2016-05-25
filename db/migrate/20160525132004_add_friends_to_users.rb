class AddFriendsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :friends, :string
  end
end
