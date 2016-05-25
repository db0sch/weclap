class RenameFriendsToUsers < ActiveRecord::Migration
  def change
    rename_column :users, :friends, :friendslist
  end
end
