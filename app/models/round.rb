class Round < ApplicationRecord
  belongs_to :game, touch: true

  belongs_to :user, optional: true # lead
   validates :user_id, presence: true, unless: :new_record?
    validate :enough_players?
  
    has_many :jokes, dependent: :nullify

  enum stage: %i[setup punchline vote results], _suffix: true

  # tidying up and choosing lead player:
  before_create :reset_players, :choose_lead
  before_create :set_last, if: :max_rounds_achieved?
  before_create :decurrent_previous_round
   after_create -> { game.increment!(:n_rounds) }
   after_create :schedule_next_stage
   after_create :broadcast_current_round
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

  def broadcast_current_round
    broadcast_render_later_to(["game", game], partial: "rounds/current_round", formats: %i[turbo_stream], locals: { game_id: game.id })
  end

  def reset_players
    game.reset_players
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
    user.update_attribute(:finished_turn, true)
    punchline_stage!
    broadcast_current_round
  end

  def move_to_vote
    vote_stage!
    broadcast_current_round
  end

  def count_votes
    jokes.each do |joke|
      author = joke.user
      author.current_score += joke.votes
      author.total_score += joke.votes
      author.save
      unless last?
        toggle(:last) if max_points_achieved?(author)
      end
    end
  end

  def max_points_achieved?(user)
    return false if game.max_points.nil?

    user.current_score >= game.max_points
  end

  def move_to_results
    results_stage!
    broadcast_current_round
  end

  def schedule_next_stage
    RoundToNextStageJob.set(wait: game.max_round_time.seconds).perform_later(id, stage)
  end

  def next_stage!
    self.update(stage: Round.stages[stage] + 1)
  end

  def schedule_next_round
    CreateNewRoundJob.set(wait: 5.seconds).perform_later(game)
  end

  def current?
    game.current_round.id == id
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
