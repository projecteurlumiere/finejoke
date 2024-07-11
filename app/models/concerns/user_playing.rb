module UserPlaying
  extend ActiveSupport::Concern

  included do 
    belongs_to :game, optional: true

    def set_lead
      self.update(lead: true, was_lead: true)
    end

    def finished_turn!
      update_attribute(:finished_turn, true)
      broadcast_turn_finished
    end

    def voted!
      update_attribute(:voted, true)
      broadcast_vote_finished
    end

    def reset_game_attributes
      self.update({ 
        game_id: nil,
        host: false,
        lead: false,
        finished_turn: false,
        voted: false,
        current_score: 0
      })
    end
  end
end
