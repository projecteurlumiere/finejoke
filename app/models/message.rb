class Message
  include ActiveModel::API

  attr_accessor :user, :game, :text

  validates :user, presence: true
  validates :game, presence: true
  validates :text, presence: true, length: { in: 1..140 }

  def broadcast
    game.broadcast_message(text, from: user)
  end

  def self.persisted?
    false
  end
end