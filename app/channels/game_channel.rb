class GameChannel < ApplicationCable::Channel
  def subscribed
    if current_game.present?
      stream_for current_game
      current_game.touch unless current_user.host?
    else 
      reject
    end
  end

  def unsubscribed
    if current_user.reload.host?
      current_game&.destroy
      current_user.update_attribute(:host, false)
    elsif current_game
      game = current_game 
      game.users.delete(current_user)
      game.touch
    end

    current_user.reset_game_attributes
  end

  private

  def current_game
    current_user.reload.game
  end
end
