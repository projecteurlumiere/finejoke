class Game < ApplicationRecord
  include Localizable
  include Games::Scheduling
  include Games::Broadcasting
  include Games::VirtualHost

  has_many :users, dependent: :nullify # players
  has_many :bans, dependent: :nullify
  belongs_to :winner, required: false, class_name: :User

  belongs_to :host, class_name: :User

  has_many :rounds, dependent: :destroy
  has_one :current_round, -> { where(current: true) }, class_name: :Round
  has_many :jokes, through: :rounds

  enum status: %i[waiting ongoing on_halt finished]

  # time in seconds
           MIN_PLAYERS = Rails.env.development? ? 2 : 3
           MAX_PLAYERS = 10
        MIN_ROUND_TIME = Rails.env.development? ? 1 : 60
        MAX_ROUND_TIME = 180 
  AFK_ROUNDS_THRESHOLD = 3
    RESULTS_STAGE_TIME = 60
    FINISHED_GAME_TIME = 180
        IDLE_GAME_TIME = 600
            MIN_POINTS = Rails.env.development? ? 1 : 10
            MAX_POINTS = 999

  validates :name, presence: true, length: { in: 1..14 }, uniqueness: true
  validates :max_players, numericality: { only_integer: true },
                          comparison: { greater_than_or_equal_to: MIN_PLAYERS, less_than_or_equal_to: MAX_PLAYERS }
  validates :max_round_time, numericality: { only_integer: true },
                             comparison: { greater_than_or_equal_to: MIN_ROUND_TIME, less_than_or_equal_to: MAX_ROUND_TIME }
  validates :max_rounds, numericality: { only_integer: true }, comparison: { greater_than_or_equal_to: 1 },
                         if: :max_rounds, allow_nil: true
  validates :max_points, numericality: { only_integer: true },
                         comparison: { greater_than_or_equal_to: MIN_POINTS, less_than_or_equal_to: MAX_POINTS }, allow_nil: true
  validate -> { errors.add(:viewers_vote, "игра должна быть открыта для зрителей") if !viewable? && viewers_vote? }
  
  normalizes :name, with: -> name { name.strip }

  before_create :generate_id

  after_create :schedule_idle_game_destroy

  after_create_commit :broadcast_game_start, if: :public?

  before_destroy -> { broadcast_remove_to_lobby }, prepend: true
  before_destroy -> { virtual_host&.destroy }, prepend: true, if: :private?

  after_destroy_commit -> { broadcast_redirect_to(game_over_path(self)) }

  def set_default_locale
    self.locale = host&.locale
  end

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
      if n_players.zero?
        user.reset_game_attributes
        finished!
        schedule_prematurely_ended_game_destroy
        return true
      end

      on_halt! if (ongoing? || waiting?) && not_enough_players?
      skip_round if ongoing? && user.lead? && current_round.setup_stage?
      was_host = user.host?

      user.reset_game_attributes

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

  def kick_user(user)
    transaction do
      Ban.issue(user, self)
      remove_user(user)
    end
  end

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
      suggestion_quota: 5,
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
    if finished?
      @unjoinable_reason = :"games.already_finished"
      return false
    end
    if n_players >= max_players
      @unjoinable_reason = :"games.too_many_players"
      return false
    end
    if user&.game
      @unjoinable_reason = :"games.already_in_game"
      return false 
    end

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
    virtual_host&.talk_later
    super
  end

  def ready_to_play?
    !(finished? && on_halt?) && enough_players?
  end

  def public?
    !private?
  end
end
