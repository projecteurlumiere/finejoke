module UserBroadcasting
  extend ActiveSupport::Concern
  
  included do 
    def broadcast_status_change
      broadcast_render_later_to(["user", self], partial: "layouts/user_status", formats: %i[turbo_stream], locals: { game_id: game&.id || 0 }) 
    end

    def broadcast_turn_finished
      broadcast_render_later_to(["game", game], partial: "games/game_user", formats: %i[turbo_stream], locals: { user_id: id, game_id: game.id }) 
    end
  end
end

