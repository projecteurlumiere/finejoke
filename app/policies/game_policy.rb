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
      (@game.viewable? || @user.joined?(@game))
  end

  def create?
    index?
  end

  def destroy?
    # @user&.host? && @user.playing?(@game)
    false
  end

  def join?
    @user &&
      @game.joinable?(by: @user)
  end

  def leave?
    @user && @user.joined?(@game)
  end

  def kick?
    # destroy? 
    @user&.host? && @user.playing?(@game)
  end

  def show_rules?
    show?
  end

  def game_over?
    true
  end
end