module JokePlaying
  extend ActiveSupport::Concern

  included do
    belongs_to :round, touch: true, optional: true
    has_one :game, through: :round, required: false

    delegate :truncate_setup, to: :round

    after_create :account_for_suggestions
    after_create :finish_user_turn
    after_create { user.increment!(:total_punchlines) }

    def finish_user_turn
      self.user.finished_turn!
    end

    def register_vote(by:) # user
      user = by
      Vote.create(user_id: user.id, round_id: round.id, joke_id: id)
    end

    def account_for_suggestions
      suggestion_ids = []

      if round.suggestions.any?
        self.setup_suggested = true
        suggestion_ids.push(*round.suggestions)
      end

      if user.suggestions.any? 
        self.punchline_suggested = true
        suggestion_ids.push(*user.suggestions)
      end

      return if suggestion_ids.none?

      # n + 1 here as it inserts them one by one
      # but there should not be too many suggestion, should it?
      # self.suggestions << Suggestion.where(id: suggestion_ids)

      # resolving n+1:
      values = suggestion_ids.map do |suggestion_id|
        "(#{self.id}, #{suggestion_id})"
      end.join(", ")

      ActiveRecord::Base.connection.execute(
        "INSERT INTO jokes_suggestions (joke_id, suggestion_id) VALUES #{values}"
      )
    end
  end
end