module JokePlaying
  extend ActiveSupport::Concern

  included do
    belongs_to :round, touch: true, optional: true
    has_one :game, through: :round, required: false

    before_create :compose_full_joke
    after_create :finish_user_turn
    after_create { user.increment!(:total_punchlines) }

    def compose_full_joke
      self.text = [setup, punchline].join(" ")
    end

    def finish_user_turn
      self.user.finished_turn!
    end

    def register_vote(by:) # user
      user = by
      Vote.create(user_id: user.id, round_id: round.id, joke_id: id)
    end
  end
end