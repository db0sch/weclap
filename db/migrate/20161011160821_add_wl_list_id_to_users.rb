class AddWlListIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :wl_list_id, :integer
  end
end
