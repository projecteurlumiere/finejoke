class CreateNewRoundJob < ApplicationJob
  queue_as :urgent

  def perform(game_id)
    # Do something later
    game = Game.find_by(id: game_id)
    return unless game
    return if game.finished? || game.on_halt? || game.waiting?

    round = game.rounds.build
    round.save
  end
end
