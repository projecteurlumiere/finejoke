class Game < ApplicationRecord
  has_many :users # players
  has_many :rounds, dependent: :destroy

  validates :name, presence: true, length: { in: 1..30 }
  validates :max_players, numericality: { only_integer: true },
                          comparison: { greater_than_or_equal_to: 3, less_than_or_equal_to: 10 }
  validates :max_round_time, numericality: { only_integer: true },
                             comparison: { greater_than_or_equal_to: 30, less_than_or_equal_to: 180 }
  validates :max_rounds, numericality: { only_integer: true }, comparison: { greater_than_or_equal_to: 1 },
                         if: :max_rounds, allow_nil: true
  validates :max_points, numericality: { only_integer: true },
                         comparison: { greater_than_or_equal_to: 2, less_than_or_equal_to: 1_000 }, allow_nil: true

  # after_create -> { broadcast_replace_to "lobby", partial: "games/list", locals: { games: Game.all }, target: "games" }

  broadcasts_to ->(_entry) { "lobby" }, inserts_by: :prepend, partial: "games/game_entry"
  broadcasts_to ->(game) { ["game", game] }, inserts_by: :replace, partial: "games/game"

  def current_round
    rounds.last
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
end
