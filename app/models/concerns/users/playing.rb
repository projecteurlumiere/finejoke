module Users
  module Playing
    extend ActiveSupport::Concern

    included do 
      belongs_to :game, optional: true
      
      # Do not check bans via association commands. only via Ban class methods!
      has_many :bans, dependent: :destroy
      has_many :votes, dependent: :nullify

      def reset_game_attributes
        transaction do
          Suggestion.where("id IN (#{suggestions.join(", ")})").destroy_all if game&.private? && suggestions.present?

          self.update({ 
            game_id: nil,
            host: false,
            hot_join: false,
            lead: false,
            voted: false,
            finished_turn: false,
            wants_to_skip_results: false,
            current_score: 0,
            suggestion_quota: 5,
            suggestions: []
          })
        end
      end

      def playing?(given_game_or_round)
         joined?(given_game_or_round) && !hot_join?
      end

      def hot_joined?(given_game_or_round)
        joined?(given_game_or_round) && hot_join?
      end

      def joined?(given_game_or_round)
        case given_game_or_round
        when Game
          game == given_game_or_round
        when Round
          game == given_game_or_round.game && given_game_or_round.current?
        end
      end

      def set_lead
        self.update(lead: true, was_lead: true)
      end

      def finished_turn!
        update_attribute(:finished_turn, true)
        @broadcast_turn_finished = true
      end

      def can_vote?(round)
        (self.playing?(round.game) || round.game.viewers_vote?) &&
          not_voted?(round)
      end

      def voted?(round)
        votes.where(round_id: round.id).any? ? true : false
      end

      def not_voted?(round)
        !voted?(round)
      end

      def voted!
        update_attribute(:voted, true)
        @broadcast_vote_finished = true
      end
    end
  end
end
