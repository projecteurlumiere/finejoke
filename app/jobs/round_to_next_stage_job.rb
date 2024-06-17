class RoundToNextStageJob < ApplicationJob
  queue_as :urgent

  def perform(round_id, stage)
    round = Round.find_by(id: round_id)

    return if round.nil?
    return if round.game.nil?
    return if round.passed?
    return if round.stage != stage || round.last_stage?

    round.next_stage!
  end
end
