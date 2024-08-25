module GameBroadcasting
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers
  
  included do 
    def broadcast_current_round
      broadcast_round(current_round)
    end

    def broadcast_round(round)
      path = round ? game_round_path(self, round) : game_rules_path(self)

      broadcast_render_later_to(["game", self], partial: "shared/fetch", formats: %i[turbo_stream], locals: { path: path })
    end

    def broadcast_user_change(votes_change: {})
      broadcast_render_later_to(["game", self], partial: "games/game_users", formats: %i[turbo_stream],
                                                locals: { 
                                                  game_id: self.id, 
                                                  votes_change: votes_change.transform_keys(&:to_s)
                                                })
      broadcast_prepend_later_to "lobby", partial: "games/game_entry", locals: { game_id: id }
    end

    def broadcast_message(text, from:)
      broadcast_render_later_to(["game", self], partial: "messages/chat_message", locals: { user: from, text: text })
    end

    def broadcast_game_start
      broadcast_create_to_lobby
    end

    def broadcast_game_over
      broadcast_current_round
      users.each(&:broadcast_status_change)
      broadcast_remove_to_lobby
    end

    def broadcast_create_to_lobby
      broadcast_prepend_later_to "lobby", partial: "games/game_entry"
    end
    
    def broadcast_remove_to_lobby
      broadcast_remove_to "lobby"
    end
  end
end

