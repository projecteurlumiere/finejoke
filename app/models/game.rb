class Game < ApplicationRecord
  include GameBroadcasting

  has_many :users # players
  belongs_to :winner, required: false, class_name: :User

  belongs_to :host, class_name: :User

  has_many :rounds, dependent: :destroy
  has_many :jokes, through: :rounds

  enum status: %i[waiting ongoing on_halt finished]

         MIN_PLAYERS = 2
         MAX_PLAYERS = 10
      MIN_ROUND_TIME = 1 
      MAX_ROUND_TIME = 180
AFK_ROUNDS_THRESHOLD = 1
  RESULTS_STAGE_TIME = 5
          MIN_POINTS = 2
          MAX_POINTS = 999

  validates :name, presence: true, length: { in: 1..30 }
  validates :max_players, numericality: { only_integer: true },
                          comparison: { greater_than_or_equal_to: MIN_PLAYERS, less_than_or_equal_to: MAX_PLAYERS }
  validates :max_round_time, numericality: { only_integer: true },
                             comparison: { greater_than_or_equal_to: MIN_ROUND_TIME, less_than_or_equal_to: MAX_ROUND_TIME }
  validates :max_rounds, numericality: { only_integer: true }, comparison: { greater_than_or_equal_to: 1 },
                         if: :max_rounds, allow_nil: true
  validates :max_points, numericality: { only_integer: true },
                         comparison: { greater_than_or_equal_to: MIN_POINTS, less_than_or_equal_to: MAX_POINTS }, allow_nil: true
  validate -> { errors.add(:viewers_vote, "cannot be set when game is not viewable") if !viewable? && viewers_vote? }

  # after_touch -> { ongoing! }, if: %i[waiting? current_round]
  after_touch -> { waiting! }, if: %i[on_halt? enough_players?]
  after_touch -> { on_halt!; broadcast_current_round }, if: %i[ongoing? not_enough_players?] 
  after_touch :skip_round, if: %i[ongoing? lead_left?]

  after_create_commit :broadcast_game_start
  after_destroy_commit :broadcast_game_over

  def add_user(user, is_host: false)
    user.reset_game_attributes
    return false unless joinable?(by: user)

    success = transaction do
      self.host = user if is_host
      user.update_attribute(:hot_join, true) if ongoing?
      self.users << user
      self.increment!(:n_players)
      save!

      true
    end

    return false unless success

    user.broadcast_status_change
    broadcast_user_change

    true
  end

  def remove_user(user)
    transaction do 
      self.users.include?(user) ? self.users.delete(user) : (return false)
      self.decrement!(:n_players)
    end

    was_host = user.host?

    user.reset_game_attributes
    user.broadcast_status_change

    self.destroy and return true if n_players == 0

    host = users.first if was_host
    
    touch
    broadcast_user_change

    true
  end

  alias_method :kick_user, :remove_user

  def integrate_hot_joined
    users.update_all(hot_join: false)
  end

  def host=(user)
    transaction do
      user.update(host: true)
      self.host_username = user.username
      super(user)
    end
  end

  def current_round
    return nil if waiting? || on_halt?
     
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
    return false if finished?
    return false if n_players >= max_players
    return false if user&.game

    true
  end

  def skip_round
    current_round.results_stage!
    current_round.touch
  end

  def conclude
    finished!
    decide_winner
    broadcast_game_over
  end

  def decide_winner
    return if max_rounds.nil? && max_points.nil?
    transaction do
      binding.irb
      self.winner = users.order(current_score: :desc).limit(1)[0]
      self.winner_score = winner.current_score
    end
  end
end
