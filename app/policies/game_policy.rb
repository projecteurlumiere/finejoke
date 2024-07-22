class GamePolicy < ApplicationPolicy
  attr_reader :user, :game

  def initialize(user, game)
    @user = user
    @game = game
  end

  def index?
    @user
  end

  def show?
    @user && 
      (@game.viewable? || @user.playing?(@game))
  end

  def create?
    index?
  end

  def destroy?
    @user&.host? && @game.users.include?(@user)
  end

  def join?
    @user &&
      @game.joinable?(by: @user)
  end

  def leave?
    @user && @user.playing?(@game)
  end

  def kick?
    destroy?
  end

  def show_rules?
    show?
  end
end