class Game < ApplicationRecord
  include Games::Scheduling
  include Games::Broadcasting
  include Games::VirtualHost

  has_many :users, dependent: :nullify # players
  belongs_to :winner, required: false, class_name: :User

  belongs_to :host, class_name: :User

  has_many :rounds, dependent: :destroy
  has_one :current_round, -> { where(current: true) }, class_name: :Round
  has_many :jokes, through: :rounds

  enum status: %i[waiting ongoing on_halt finished]

  # time in seconds
           MIN_PLAYERS = 2
           MAX_PLAYERS = 10
        MIN_ROUND_TIME = 1
        MAX_ROUND_TIME = 180 
  AFK_ROUNDS_THRESHOLD = 1
    RESULTS_STAGE_TIME = 60
    FINISHED_GAME_TIME = 180
        IDLE_GAME_TIME = 180
            MIN_POINTS = 2
            MAX_POINTS = 999

  validates :name, presence: true, length: { in: 1..14 }
  validates :max_players, numericality: { only_integer: true },
                          comparison: { greater_than_or_equal_to: MIN_PLAYERS, less_than_or_equal_to: MAX_PLAYERS }
  validates :max_round_time, numericality: { only_integer: true },
                             comparison: { greater_than_or_equal_to: MIN_ROUND_TIME, less_than_or_equal_to: MAX_ROUND_TIME }
  validates :max_rounds, numericality: { only_integer: true }, comparison: { greater_than_or_equal_to: 1 },
                         if: :max_rounds, allow_nil: true
  validates :max_points, numericality: { only_integer: true },
                         comparison: { greater_than_or_equal_to: MIN_POINTS, less_than_or_equal_to: MAX_POINTS }, allow_nil: true
  validate -> { errors.add(:viewers_vote, "игра должна быть открыта для зрителей") if !viewable? && viewers_vote? }

  before_create :generate_id

  after_create :schedule_idle_game_destroy

  after_create_commit :broadcast_game_start, if: :public?
  after_destroy_commit -> { broadcast_redirect_to(game_over_path(self)) }

  # careful of local id vs model's self.id
  def generate_id
    id = SecureRandom.hex(4) until id.present? && Game.where(id:).none?
    self.id = id
  end

  def add_user(user, is_host: false)
    transaction do
      raise ActiveRecord::RecordInvalid unless joinable?(by: user)
      user.reset_game_attributes
      self.host = user if is_host
      user.update_attribute(:hot_join, true) if ongoing?
      self.users << user
      self.increment!(:n_players)
      waiting! if on_halt? && enough_players?

      save!
      touch
    end

    user.broadcast_status_change
    broadcast_user_change

    true
  rescue ActiveRecord::RecordInvalid
    return false
  end

  def remove_user(user)
    transaction do
      self.users.include?(user) ? self.users.delete(user) : (return false)
      self.decrement!(:n_players)
      on_halt! if (ongoing? || waiting?) && not_enough_players?
      skip_round if ongoing? && user.lead?
      was_host = user.host?

      user.reset_game_attributes

      self.destroy and return true if n_players.zero?

      self.host = users.first; broadcast_current_round if was_host

      save!
      touch

      broadcast_user_change
      user.broadcast_status_change

      true
    end
  rescue ActiveRecord::RecordInvalid
    return false
  end

  alias_method :kick_user, :remove_user

  def integrate_hot_joined
    users.update_all(hot_join: false)
  end

  def host=(user)
    transaction do
      user.update(host: true)
      super(user)
      save
    end
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
      wants_to_skip_results: false,
      lead: false,
      voted: false,
      suggestions: []
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
    current_round.move_to_results
  end

  def conclude
    transaction do
      finished!
      decide_winner
      users.update_all("total_games = total_games + 1")
      # current round is necessary because sometimes it is used to get game instance:
      if current_round
        rounds.last.update_attribute(:current, true)
        current_round.last!
        current_round.store_change_timings(nil, nil)
      end
      broadcast_game_over
    ensure
      schedule_idle_game_destroy(force: true)
    end
  end

  def decide_winner
    return if max_rounds.nil? && max_points.nil?
    
    transaction do
      self.winner = users.order(current_score: :desc).limit(1)[0]
      self.winner.increment!(:total_wins)
      self.winner_score = winner.current_score
    end
  end

  def on_halt!
    schedule_game_conclude
    current_round&.update_attribute(:current, false)
    reset_current_round
    broadcast_current_round
    super
  end

  def waiting!
    schedule_game_conclude
    super
  end

  def ready_to_play?
    !(finished? && on_halt?) && enough_players?
  end

  def public?
    !private?
  end
end
