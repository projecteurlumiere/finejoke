class MessagePolicy < ApplicationPolicy
  attr_reader :user, :message

  def initialize(user, message)
    @user = user
    @message = message
  end

  def create?
    @user && @message.game.users.include?(@user)
  end
end 