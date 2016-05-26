class FriendshipPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
    def index
      true
    end
  end
end
