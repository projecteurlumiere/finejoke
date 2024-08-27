# unused
class NotifyGameJob < ApplicationJob
  queue_as :default

  def perform(game_id, message)
    game = Game.find_by(id: game_id)
    return unless game
    
    game.broadcast_flash(message)
  end
end
