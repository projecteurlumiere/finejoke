class JokePolicy < ApplicationPolicy
  attr_reader :user, :joke

  def initialize(user, joke)
    @user = user
    @joke = joke
    @round = joke.round
    @game = @round.game
  end

  def create?
    @user.playing?(@game) && 
      @round.current? &&
      !@user.lead? && !@user.finished_turn?
  end

  def update?
    (@user.playing?(@game) || @game.viewers_vote?) &&
      @round.current? &&
      @user.can_vote?(@round)
  end
end