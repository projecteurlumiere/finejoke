class FinishGameJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    game = Game.find_by(id: game_id)

    return if game.nil?

    game.destroy
  end
end
