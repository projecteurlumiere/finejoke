module UserPlaying
  extend ActiveSupport::Concern

  included do 
    belongs_to :game, optional: true

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
      broadcast_turn_finished
    end

    def can_vote?(round)
      (self.playing?(round.game) || round.game.viewers_vote?) &&
        not_voted?(round)
    end

    def voted?(round)
      round.votes.find_by(user_id: self) ? true : false
    end

    def not_voted?(round)
      !voted?(round)
    end

    def voted!
      update_attribute(:voted, true)
      broadcast_vote_finished
    end

    def reset_game_attributes
      self.update({ 
        game_id: nil,
        host: false,
        hot_join: false,
        lead: false,
        voted: false,
        finished_turn: false,
        current_score: 0,
        suggestions: []
      })
    end
  end
end
