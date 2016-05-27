class Friendship < ActiveRecord::Base
  belongs_to :friend, class_name: 'User', foreign_key: :friend_id
  belongs_to :buddy, class_name: 'User', foreign_key: :buddy_id
  validates :friend_id, uniqueness: { scope: :buddy_id }
  validate do
    friend_uniqueness
  end

  private

  def friend_uniqueness

    buddies = Friendship.select{|f| f.friend_id == self.buddy_id}
    buddies.each do |buddy|
      if buddy.buddy_id == self.friend_id
        errors.add(:friend_id, 'uniqueness not true')
        return false
      end
    end
  end
end
