class Round < ApplicationRecord
  belongs_to :game, touch: true

  belongs_to :user, optional: true # lead
   validates :user_id, presence: true, unless: :new_record?
    validate :enough_players?
  
    has_many :jokes, dependent: :nullify
    has_many :votes, dependent: :nullify

  enum stage: %i[setup punchline vote results], _suffix: true
  attr_accessor :votes_change

  # tidying up and choosing lead player:
  before_create :reset_players, :choose_lead
  before_create :set_last, if: :max_rounds_achieved?
  before_create :decurrent_previous_round
   after_create -> { game.increment!(:n_rounds) }
   after_create -> { game.ongoing! if game.waiting? }
   after_create :schedule_next_stage
   after_create -> { broadcast_round(self) }
   after_create -> { game.broadcast_user_change }
   # after_create -> { touch }
  # when lead updated round with setup:
   before_update :random_setup, if: %i[punchline_stage?], unless: %i[setup?]
   after_update :move_to_punchline, if: %i[setup_stage? setup?]
   # after_update -> { touch }
  # called every time joke is created:
    after_touch :move_to_vote, if: %i[punchline_stage? turns_finished?]
    after_touch :count_votes, :move_to_results, if: %i[vote_stage? votes_finished?]
    after_touch :schedule_next_round, if: :results_stage?, unless: :last?
    after_touch :schedule_next_stage, unless: %i[results_stage? last?]
    # after_touch -> { game.touch }

  delegate :broadcast_current_round, to: :game
  delegate :broadcast_round, to: :game
  delegate :current_round, to: :game
  delegate :reset_players, to: :game

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

  def set_last
    self.last = true
  end

  def decurrent_previous_round
    previous_round = game.rounds[-2]
    previous_round.update_attribute(:current, false) if previous_round
  end

  def random_setup
    self.setup = "i am a random setup to be implemented later"
  end

  def move_to_punchline
    user.finished_turn!
    punchline_stage!
    broadcast_current_round
  end

  def move_to_vote
    vote_stage!
    broadcast_current_round
  end

  def count_votes
    self.votes_change = jokes.map do |joke|
      author = joke.punchline_author
      author.current_score += joke.n_votes
      author.total_score += joke.n_votes
      author.save

      unless last?
        toggle(:last) if max_points_achieved?(author)
      end

      [author.id, joke.n_votes]
    end.to_h
  end

  def max_points_achieved?(user)
    return false if game.max_points.nil?

    user.current_score >= game.max_points
  end

  def move_to_results
    results_stage!
    broadcast_current_round
    game.broadcast_user_change(votes_change: votes_change)
  end

  def schedule_next_stage
    RoundToNextStageJob.set(wait: game.max_round_time.seconds).perform_later(id, stage)
  end

  def next_stage!
    stage_number = Round.stages[stage]
    self.send("move_to_#{Round.stages.to_a[stage_number + 1][0]}")
  end

  def schedule_next_round
    CreateNewRoundJob.set(wait: Game::RESULTS_STAGE_TIME).perform_later(game.id)
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
    game.users.find_by(finished_turn: false) ? false : true
  end

  def votes_finished?
    game.users.find_by(voted: false) ? false : true
  end
end
