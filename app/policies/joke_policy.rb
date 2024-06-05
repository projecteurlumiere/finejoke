class JokePolicy < ApplicationPolicy
  attr_reader :user, :joke

  def initialize(user, joke)
    @user = user
    @joke = joke
    @round = joke.round
    @game = @round.game
  end

  def create?
    @game.users.include?(@user) && 
    @game.current_round == @round &&
    !@user.lead?
  end

  def update?
    @game.users.include?(@user) && 
    @game.current_round == @round &&
    !@user.voted?
  end
end