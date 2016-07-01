class FriendshipsController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index

#2do check against pundit proper use
  def index
    @my_friends = current_user.friendslist
    @friends = current_user.get_friends_list
    # @friendships = policy_scope(Friendship)
  end
end
