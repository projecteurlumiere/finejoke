class GameChannel < ApplicationCable::Channel
  def subscribed
    current_game.present? ? stream_for(current_game) : reject
  end

  def unsubscribed
    if current_user.reload.host?
      current_game&.destroy
      current_user.update_attribute(:host, false)
    else
      current_game.users.delete(current_user) if current_game
    end
  end

  private

  def current_game
    current_user.reload.game
  end
end
