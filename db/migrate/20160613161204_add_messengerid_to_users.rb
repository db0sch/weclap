class AddMessengeridToUsers < ActiveRecord::Migration
  def change
    add_column :users, :messenger_id, :string
  end
end
