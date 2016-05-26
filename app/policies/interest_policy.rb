class InterestPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    !user.interests.map(&:movie).include?(record.movie)
    # !user.interests.map(&:movie).include?(record)
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end
end
