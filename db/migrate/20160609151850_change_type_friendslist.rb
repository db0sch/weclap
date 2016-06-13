class ChangeTypeFriendslist < ActiveRecord::Migration
  def change
    rename_column :users, :friendslist, :full_name_friendlist
    add_column :users, :friendslist, :json
  end
end
