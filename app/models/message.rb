class Message
  include ActiveModel::API

  attr_accessor :user, :game, :text

  validates :user, presence: true
  validates :game, presence: true
  validates :text, presence: true, length: { in: 1..140 }

  def broadcast
    game.broadcast_message(text, from: user)

    return true unless game.virtual_host.present? && text.downcase.start_with?(I18n.t(:"message.virtual_host_address").downcase)

    ReplyJob.perform_later(game.virtual_host.id, user.username, text)
  end

  def self.persisted?
    false
  end
end