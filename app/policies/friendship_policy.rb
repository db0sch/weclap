class FriendshipPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where('friend_id = ? or buddy_id = ?', user.id, user.id)
    end

    def index?
      user == current_user
    end
  end
end
