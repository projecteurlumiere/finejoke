class RoundPolicy < ApplicationPolicy
  attr_reader :user, :round

  def initialize(user, round)
    @user = user
    @round = round
    @game = round.game
  end

  def show?
    @game.current_round == @round &&
      (@game.viewable? || @user.playing?(@game))
  end

  def create?
   @user.playing?(@game) &&
      %w[waiting on_halt].include?(@game.status) &&
      @user.host?
  end

  def update?
    @user.playing?(@game) &&
      @game.current_round == @round &&
      @user.lead?
  end
end