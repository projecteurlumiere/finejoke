class CreateNewRoundJob < ApplicationJob
  queue_as :urgent

  def perform(game)
    # Do something later
    round = game.rounds.build
    round.choose_lead
    round.save
    game.touch
  end
end
