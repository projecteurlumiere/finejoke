class AwardPolicy < ApplicationPolicy
  attr_reader :user, :award

  def initialize(user, award)
    @user = user
    @award = award
  end

  def gift?
    @user && @user != @award.user
  end
end