class FriendshipsController < ApplicationController
  def index
    @friends = friend_array_builder
    @friendships = policy_scope(Friendship)
  end


  private

  def friend_array_builder
    friend_array = []

    if !current_user.buddies.nil?
      current_user.buddies.each do |b|
        friend_array << User.find(b.friend_id)
      end
    end
    if !current_user.friends.nil?
      current_user.friends.each do |b|
        friend_array << User.find(b.buddy_id)
      end
    end
    return friend_array
  end
end
