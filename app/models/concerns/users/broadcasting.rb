module Users
  module Broadcasting
    extend ActiveSupport::Concern
    
    included do 
      after_commit :broadcast_turn_finished, if: -> { @broadcast_turn_finished }
      after_commit :broadcast_vote_finished, if: -> { @broadcast_vote_finished }

      def broadcast_status_change
        broadcast_render_later_to(["user", self], partial: "layouts/user_status", formats: %i[turbo_stream], locals: { game_id: game&.id || 0 }) 
      end

      def broadcast_turn_finished
        broadcast_render_later_to(["game", game], partial: "games/game_user", formats: %i[turbo_stream], locals: { 
          user_id: id, game_id: game.id, current_round_votes: @current_round_votes || [], 
        }) 
      end

      def broadcast_vote_finished
        @current_round_votes = [self.id]
        broadcast_turn_finished
      end
    end
  end
end

