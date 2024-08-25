class Round < ApplicationRecord
  belongs_to :game, touch: true

  belongs_to :user, optional: true # lead
   validates :user_id, presence: true, unless: :new_record?
    validate :enough_players?
  
    has_many :jokes, dependent: :nullify
    has_many :votes, dependent: :nullify

  enum stage: %i[setup punchline vote results], _suffix: true
  attr_accessor :votes_change

  validates :setup, length: { in: 1..200 }, on: :update

  # tidying up and choosing lead player:
  before_create :reset_players, :choose_lead
  before_create :last!, if: :max_rounds_achieved?, unless: :last?
  before_create :decurrent_previous_round
  after_create -> {
    game.increment!(:n_rounds)
    game.ongoing! if game.waiting?
    game.integrate_hot_joined
    schedule_next_stage
    broadcast_round(self)
    game.broadcast_user_change
  }

  # when lead updated round with setup:
  before_update -> { move_to_punchline }, if: %i[setup_stage? setup? setup_changed?]

  after_touch -> {
    move_to_vote and return if time_to_vote?
    move_to_results and return if time_for_results?
  }

  # called every time joke is created:
  # after_touch :move_to_vote, if: %i[punchline_stage? turns_finished?]
  # after_touch :count_votes, :move_to_results, if: %i[vote_stage? votes_finished?]
  # after_touch :schedule_next_stage, unless: %i[results_stage? last?]
  # after_touch -> { game.touch }

  delegate :broadcast_current_round, to: :game
  delegate :broadcast_round, to: :game
  delegate :current_round, to: :game
  delegate :reset_players, to: :game


  def move_to_punchline
    user.finished_turn!
    random_setup if setup.nil?
    punchline_stage!
    broadcast_current_round
    schedule_next_stage
  end

  def time_to_vote?
    punchline_stage? && turns_finished?
  end

  def time_for_results?
    vote_stage? && votes_finished?
  end

  def move_to_vote
    handle_no_jokes and return if jokes.none?

    vote_stage!
    broadcast_current_round
    schedule_next_stage
  end

  def move_to_results
    count_votes
    results_stage!
    broadcast_current_round
    game.broadcast_user_change(votes_change: votes_change)

    if last? 
      schedule_game_finish
    else
      schedule_next_round
    end
  end

  def handle_no_jokes
    game.increment!(:afk_rounds)
    update_attribute(:last, true) if game.afk_rounds >= Game::AFK_ROUNDS_THRESHOLD


    self.votes_change = {}

    move_to_results

    true
  end

  def choose_lead 
    self.user_id = game.choose_lead.id
  end

  def lead
    user
  end

  def enough_players? 
    errors.add(:game_id, "must have enought players") unless game.enough_players?
  end

  def max_rounds_achieved?
    return false if game.max_rounds.nil?

    game.max_rounds == game.rounds.count + 1 # one being this new round
  end

  def last!
    self.last = true
  end

  def decurrent_previous_round
    # why not -1?
    previous_round = game.rounds.find_by(current: true) # searches only persistent records
    previous_round&.update_attribute(:current, false)
  end

  def random_setup
    self.setup = "i am a random setup to be implemented later"
  end

  def count_votes
    self.votes_change = jokes.map do |joke|
      author = joke.punchline_author
      author.current_score += joke.n_votes
      author.total_score += joke.n_votes
      author.save

      unless last?
        last! if max_points_achieved?(author)
      end

      [author.id, joke.n_votes]
    end.to_h
  end

  def max_points_achieved?(user)
    return false if game.max_points.nil?

    user.current_score >= game.max_points
  end

  def store_change_timings(change_deadline, change_scheduled_at = Time.current)
    update_columns(change_deadline:, change_scheduled_at:)
  end

  def schedule_next_stage
    deadline = Time.current + game.max_round_time
    RoundToNextStageJob.set(wait_until: deadline).perform_later(id, stage)
    store_change_timings(deadline)
  end

  def next_stage!
    stage_number = Round.stages[stage]
    raise "cannot go past the last stage" if stage_number.nil?
    self.send("move_to_#{Round.stages.to_a[stage_number + 1][0]}")
  end

  def schedule_next_round
    deadline = Time.current + Game::RESULTS_STAGE_TIME
    CreateNewRoundJob.set(wait_until: deadline).perform_later(game.id)
    store_change_timings(deadline)
  end

  def schedule_game_finish
    deadline = Time.current + Game::RESULTS_STAGE_TIME
    FinishGameJob.set(wait_until: deadline).perform_later(game.id)
    store_change_timings(deadline)
  end

  def current?
    game.current_round == self
  end

  def passed?
    !current?
  end

  def last_stage?
    stage == Round.stages.length
  end

  def turns_finished?
    game.users.find_by(finished_turn: false, hot_join: false) ? false : true
  end

  def votes_finished?
    game.users.find_by(voted: false, hot_join: false) ? false : true
  end
end
