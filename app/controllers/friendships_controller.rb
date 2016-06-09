class FriendshipsController < ApplicationController
  def index
    @friends = JSON.parse(current_user.friendslist)
    @friendships = policy_scope(Friendship)
  end
end
