class CreateNewRoundJob < ApplicationJob
  queue_as :urgent

  def perform(game_id, current_round_id)
    # Do something later
    current_round = Round.find_by(id: current_round_id)
    return if current_round.nil? || current_round.passed?
    
    game = Game.find_by(id: game_id)
    return unless game.ongoing?

    new_round = game.rounds.build
    new_round.save
  end
end
