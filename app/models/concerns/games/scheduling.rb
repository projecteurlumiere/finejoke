module Games
  module Scheduling
    extend ActiveSupport::Concern
    
    included do 
      def schedule_game_conclude(notify: true, force: false)
        ConcludeGameJob.set(wait_until: Time.now + Game::IDLE_GAME_TIME.seconds)
                       .perform_later(id, updated_at, notify:, force:)
      end

      def schedule_idle_game_destroy(notify: true, force: false)
        DestroyIdleGameJob.set(wait_until: Time.now + (Game::IDLE_GAME_TIME * 0.75).seconds)
                          .perform_later(id, updated_at, notify:, force:)
      end

      def schedule_prematurely_ended_game_destroy(notify: false, force: true)
        DestroyIdleGameJob.perform_later(id, updated_at, notify:, force:)
      end
    end
  end
end