class ProfilePolicy < ApplicationPolicy
  attr_reader :user, :desired_user

  def initialize(user, desired_user)
    @user = user
    @desired_user = desired_user
  end

  def show?
    @user
  end

  def edit?
    @user == @desired_user
  end

  def update?
    @user == @desired_user
  end
end