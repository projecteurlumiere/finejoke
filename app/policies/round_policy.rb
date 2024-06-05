class RoundPolicy < ApplicationPolicy
  attr_reader :user, :round

  def initialize(user, round)
    @user = user
    @round = round
    @game = round.game
  end

  def show?
    @game.users.include?(@user) && 
    @game.current_round == @round
  end

  def create?
    @game.users.include?(@user) &&
    %w[waiting on_halt].include?(@game.status) &&
    @user.host?
  end

  def update?
    @game.users.include?(@user) && 
    @game.current_round == @round &&
    @user.lead?
  end
end