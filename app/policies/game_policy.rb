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
    @user && @game.users.include?(@user)
  end

  def create?
    @user
  end

  def destroy?
    @user&.host? && @game.users.include?(@user)
  end

  def join?
    @game.joinable?(by: @user)
  end

  def leave?
    show?
  end

  def kick?
    destroy?
  end
end