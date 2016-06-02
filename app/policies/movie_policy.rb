class MoviePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.order("Random()").limit(100)
    end
  end
end
