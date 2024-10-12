module Games
  module Broadcasting
    extend ActiveSupport::Concern
    include Rails.application.routes.url_helpers

    included do 
      def stream_name
        GameChannel.broadcasting_for(self)
      end

      def lobby_stream_name
        "lobby_#{locale}"
      end

      def broadcast_current_round
        broadcast_round(current_round)
      end

      def broadcast_round(round)
        path = round ? game_round_path(self, round) : game_rules_path(self)

        broadcast_render_later_to(["game", self], 
          partial: "shared/fetch", 
          formats: %i[turbo_stream], 
          locals: { path: path })
      end

      def broadcast_user_change(votes_change: {})
        broadcast_render_later_to(stream_name, 
            partial: "games/game_users", 
            formats: %i[turbo_stream],
            locals: { 
              game_id: self.id, 
              votes_change: votes_change.transform_keys(&:to_s)
            })
        broadcast_replace_later_to lobby_stream_name,
          partial: "games/game_entry_n_users",
          target: "game_#{id}_n_players",
          locals: { game_id: id }
      end

      def broadcast_message(text, from:)
        broadcast_render_later_to(stream_name, partial: "messages/chat_message", 
          locals: { id: from.id || "", username: from.username, text: text })
      end

      def broadcast_game_start
        broadcast_create_to_lobby
      end

      def broadcast_game_over
        broadcast_current_round
        users.each(&:broadcast_status_change)
        broadcast_remove_to_lobby
      end

      # either { notice: "your_string" } or { alert: "your_string" }
      def broadcast_flash(flashable = { alert: "no flash message was supplied" })
        broadcast_render_later_to(stream_name, partial: "shared/flash", locals: { flashable: })
      end

      def broadcast_redirect_to(path)
        broadcast_render_to(stream_name, partial: "shared/redirect_to", locals: { path: })
      end

      def broadcast_create_to_lobby
        broadcast_prepend_later_to lobby_stream_name, partial: "games/game_entry"
      end
      
      def broadcast_remove_to_lobby
        return if private?
        
        broadcast_remove_to lobby_stream_name
      end
    end
  end
end

