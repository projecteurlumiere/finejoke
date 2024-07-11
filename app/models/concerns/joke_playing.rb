module JokePlaying
  extend ActiveSupport::Concern

  included do
    belongs_to :round, touch: true, optional: true

    before_create :compose_full_joke
    after_create :finish_user_turn
    after_create -> { round.touch if round&.turns_finished? }

    def compose_full_joke
      self.text = [setup, punchline].join(" ")
    end

    def finish_user_turn
      self.user.finished_turn!
    end

    def register_vote(by:) # user
      user = by
      ActiveRecord::Base.transaction do
        self.increment(:votes) 
        self.save && user.voted!
      end
    end
  end
end