class Game < ApplicationRecord
  has_many :users # players
  has_many :rounds, dependent: :destroy

  enum status: %i[waiting ongoing on_halt finished]

  validates :name, presence: true, length: { in: 1..30 }
  validates :max_players, numericality: { only_integer: true },
                          comparison: { greater_than_or_equal_to: 2, less_than_or_equal_to: 10 }
  # max round time must be at least 30 in prod 
  validates :max_round_time, numericality: { only_integer: true },
                             comparison: { greater_than_or_equal_to: 1, less_than_or_equal_to: 180 }
  validates :max_rounds, numericality: { only_integer: true }, comparison: { greater_than_or_equal_to: 1 },
                         if: :max_rounds, allow_nil: true
  validates :max_points, numericality: { only_integer: true },
                         comparison: { greater_than_or_equal_to: 2, less_than_or_equal_to: 1_000 }, allow_nil: true

  # after_create -> { broadcast_replace_to "lobby", partial: "games/list", locals: { games: Game.all }, target: "games" }
  after_touch -> { ongoing! }, if: %i[waiting? current_round]
  after_touch -> { waiting! }, if: %i[on_halt? enough_players?]
  after_touch -> { on_halt! }, if: %i[ongoing? not_enough_players?] 
  after_touch :skip_round, if: %i[ongoing? lead_left?]

  broadcasts_to ->(_entry) { "lobby" }, inserts_by: :prepend, partial: "games/game_entry"
  # broadcasts_to ->(game) { ["game", game] }, inserts_by: :replace, partial: "games/game"

  after_create_commit -> { broadcast_prepend_later_to ["game", self] }
  after_update_commit -> { broadcast_replace_later_to ["game", self] }
  after_destroy_commit -> { broadcast_render_to(["game", self], partial: "games/game_over", locals: { game: self }) }

  def add_user(user)
    user.reset_game_attributes
    self.users << user unless users.include?(user) && joinable?
  end

  def current_round
    rounds.find_by(current: true)
  end

  def choose_lead
    lead = users.find_by(was_lead: false)
    if lead.nil?
      reset_lead
      lead = users.order("RANDOM()").find_by!(was_lead: false)
    end

    users.update_all(lead: false)
    lead.set_lead

    lead
  end

  def broadcast_message(text, from:)
    broadcast_render_later_to(["game", self], partial: "games/chat_message", locals: { user: from, text: text })
  end

  def reset_lead
    users.update_all(was_lead: false)
  end

  def reset_players
    users.update_all(
      finished_turn: false,
      lead: false,
      finished_turn: false,
      voted: false
    )
  end

  def lead_left?
    users.exclude?(current_round.lead)
  end

  def enough_players?
    (2..max_players).cover?(users.count)
  end

  def not_enough_players?
    users.count < 2 # min players
  end

  def joinable?(by: nil) # user
    user = by
    return false if users.count >= max_players

    true
  end

  def skip_round
    current_round.results_stage!
    current_round.touch
  end
end
