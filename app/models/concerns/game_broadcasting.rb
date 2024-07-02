module GameBroadcasting
  extend ActiveSupport::Concern
  
  included do 
    def broadcast_current_round
      broadcast_render_later_to(["game", self], partial: "rounds/current_round", formats: %i[turbo_stream], locals: { game_id: id })
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
      broadcast_render_later_to(["game", self], partial: "games/game_over", locals: { game_id: id })
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

