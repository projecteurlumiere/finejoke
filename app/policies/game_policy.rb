class GamePolicy < ApplicationPolicy
  attr_reader :user, :game

  def initialize(user, game)
    @user = user
    @game = game
  end

  def index?
    true
  end

  def show?
    @user 
    # && @game.joinable? 
    # || game.viewable?
  end

  def create?
    @user
  end

  def update?
    @user && @game.users.include?(@user)
  end

  def destroy?
    @user&.host? && @game.users.include?(@user)
  end

  def leave?
    update?
  end
end