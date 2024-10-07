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
    @user && has_no_ban?(@user, @game) &&
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

  private 

  def has_no_ban?(user, game)
    !(Ban.user_banned_from_joining_games?(user) ||
      Ban.user_banned_in_game?(user, game))
  end
end