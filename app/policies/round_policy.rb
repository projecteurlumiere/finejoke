class RoundPolicy < ApplicationPolicy
  attr_reader :user, :round

  def initialize(context, round)
    @user = context[:user]
    @round = round
    @game = context[:game]

    throw Pundit::NotAuthorizedError if @round != Round && @round.game != @game
  end

  def show?
    @game.current_round == @round &&
      (@game.viewable? || @user.joined?(@game))
  end

  def show_current?
    @game.viewable? || @user.joined?(@game)
  end

  def create?
   @game.host == @user &&
      %w[waiting on_halt].include?(@game.status)
  end

  def update?
    @user.playing?(@game) &&
      @game.current_round == @round &&
      @user.lead?
  end
end