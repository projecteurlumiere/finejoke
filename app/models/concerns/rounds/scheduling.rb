module Rounds
  module Scheduling
    extend ActiveSupport::Concern
    
    included do 
      def schedule_next_stage
        # deadline = Time.current + 9999
        deadline = Time.current + game.max_round_time
        RoundToNextStageJob.set(wait_until: deadline).perform_later(id, stage)
        store_change_timings(deadline)
      end

      def schedule_next_round
        # deadline = Time.current + 10
        deadline = Time.current + Game::RESULTS_STAGE_TIME
        CreateNewRoundJob.set(wait_until: deadline).perform_later(game.id)
        store_change_timings(deadline)
      end

      def schedule_game_finish
        # deadline = Time.current + 9999
        deadline = Time.current + Game::RESULTS_STAGE_TIME
        ConcludeGameJob.set(wait_until: deadline).perform_later(game.id, notify: false, force: true)
        store_change_timings(deadline)
      end

      def store_change_timings(change_deadline, change_scheduled_at = Time.current)
        update_columns(change_deadline:, change_scheduled_at:)
      end

      def next_stage!
        transaction do 
          stage_number = Round.stages[stage]
          raise "cannot go past the last stage" if stage_number.nil?
          self.send("move_to_#{Round.stages.to_a[stage_number + 1][0]}")
        end
      end
    end
  end
end