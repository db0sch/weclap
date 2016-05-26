class Friendship < ActiveRecord::Base
  belongs_to :friend, class_name: 'User', foreign_key: :friend_id
  belongs_to :buddy, class_name: 'User', foreign_key: :buddy_id


  validates :friend_id, uniqueness: { scope: :buddy_id }
end
