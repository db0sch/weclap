class Friendship < ActiveRecord::Base
  belongs_to :friend, class_name: 'User', foreign_key: :friend_id
  belongs_to :buddy, class_name: 'User', foreign_key: :buddy_id
end
