class FriendshipsController < ApplicationController
  def index
    @friends = current_user.friendslist
    @friendships = policy_scope(Friendship)
  end
end
