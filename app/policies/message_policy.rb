class MessagePolicy < ApplicationPolicy
  attr_reader :user, :message

  def initialize(user, message)
    @user = user
    @message = message
  end

  def create?
    @user&.joined?(@message.game)
  end
end 