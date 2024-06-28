class Game < ApplicationRecord
  has_many :users # players
  has_many :rounds, dependent: :destroy

  enum status: %i[waiting ongoing on_halt finished]

         MIN_PLAYERS = 2
         MAX_PLAYERS = 10
      MIN_ROUND_TIME = 1 
      MAX_ROUND_TIME = 180
  RESULTS_STAGE_TIME = 5
          MIN_POINTS = 2
          MAX_POINTS = 1_000

  validates :name, presence: true, length: { in: 1..30 }
  validates :max_players, numericality: { only_integer: true },
                          comparison: { greater_than_or_equal_to: MIN_PLAYERS, less_than_or_equal_to: MAX_PLAYERS }
  validates :max_round_time, numericality: { only_integer: true },
                             comparison: { greater_than_or_equal_to: MIN_ROUND_TIME, less_than_or_equal_to: MAX_ROUND_TIME }
  validates :max_rounds, numericality: { only_integer: true }, comparison: { greater_than_or_equal_to: 1 },
                         if: :max_rounds, allow_nil: true
  validates :max_points, numericality: { only_integer: true },
                         comparison: { greater_than_or_equal_to: MIN_POINTS, less_than_or_equal_to: MAX_POINTS }, allow_nil: true

  # after_create -> { broadcast_replace_to "lobby", partial: "games/list", locals: { games: Game.all }, target: "games" }
  after_touch -> { ongoing! }, if: %i[waiting? current_round]
  after_touch -> { waiting! }, if: %i[on_halt? enough_players?]
  after_touch -> { on_halt! }, if: %i[ongoing? not_enough_players?] 
  after_touch :skip_round, if: %i[ongoing? lead_left?]

  broadcasts_to ->(_entry) { "lobby" }, inserts_by: :prepend, partial: "games/game_entry"
  # broadcasts_to ->(game) { ["game", game] }, inserts_by: :replace, partial: "games/game"

  # after_create_commit -> { broadcast_prepend_later_to ["game", self] }
  # after_update_commit -> { broadcast_replace_later_to ["game", self] }
  after_destroy_commit -> {
    broadcast_render_to(["game", self], partial: "games/game_over", locals: { game: self })
    users.each(&:broadcast_status_change)
  }

  def add_user(user, host: false)
    user.reset_game_attributes
    return false unless joinable?(by: user)

    self.users << user

    user.update(host: true) if host
    user.broadcast_status_change
    broadcast_user_change

    true
  end

  def remove_user(user)
    self.users.include?(user) ? self.users.delete(user) : (return false)
    user_was_host = user.host?

    user.reset_game_attributes
    user.broadcast_status_change

    self.destroy and return true if users.empty?

    choose_new_host if user_was_host
    
    touch
    broadcast_user_change

    true
  end

  alias_method :kick_user, :remove_user

  def broadcast_user_change(votes_change: {})
    broadcast_render_later_to(["game", self], partial: "games/game_users", formats: %i[turbo_stream],
                                              locals: { 
                                                game_id: self.id, 
                                                votes_change: votes_change.transform_keys(&:to_s)
                                              })
  end

  def broadcast_message(text, from:)
    broadcast_render_later_to(["game", self], partial: "messages/chat_message", locals: { user: from, text: text })
  end

  def host
    users.find_by(host: true)
  end

  def choose_new_host
    users.first.update(host: true)
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

    def reset_lead
    users.update_all(was_lead: false)
  end

  def reset_players
    users.update_all(
      finished_turn: false,
      lead: false,
      voted: false
    )
  end

  def lead_left?
    users.exclude?(current_round.lead)
  end

  def enough_players?
    (MIN_PLAYERS..max_players).cover?(users.count)
  end

  def not_enough_players?
    users.count < MIN_PLAYERS # min players
  end

  def joinable?(by: nil) # user
    user = by
    return false if users.count >= max_players
    return false if user&.game

    true
  end

  def skip_round
    current_round.results_stage!
    current_round.touch
  end
end
