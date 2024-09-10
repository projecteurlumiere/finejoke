class Round < ApplicationRecord
  include RoundScheduling
  
  belongs_to :game, touch: true
  belongs_to :user, optional: true # lead
  
   validates :setup, length: { in: 1..Joke::SETUP_MAX_LENGTH }, if: :setup_changed?
   # validates :setup_short, length: { in: 1..55 }, if: %i[setup setup_changed?]
   validates :user_id, presence: true, unless: :new_record?
    validate :game_is_ready
  
    has_many :jokes, dependent: :nullify
    has_many :votes, dependent: :nullify

  enum stage: %i[setup punchline vote results], _suffix: true
  attr_accessor :votes_change

  delegate *%i[broadcast_current_round broadcast_round current_round reset_players], to: :game

  # tidying up and choosing lead player:
  before_create -> {
    reset_players
    choose_lead
    last! if max_rounds_achieved? && !last?
    decurrent_previous_round
  }

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
  before_update :truncate_setup, if: %i[setup? setup_changed?]

  after_touch -> {
    move_to_vote and return if time_to_vote?
    move_to_results and return if time_for_results?
  }

  def move_to_punchline
    user.finished_turn!
    setup.nil? ? random_setup : user.increment!(:total_setups)
    punchline_stage!
    broadcast_current_round
    schedule_next_stage
  end

  def time_to_vote?
    punchline_stage? && turns_finished?
  end

  def move_to_vote
    handle_no_jokes and return if jokes.none?

    vote_stage!
    broadcast_current_round
    schedule_next_stage
  end

  def handle_no_jokes
    game.increment!(:afk_rounds)
    update_attribute(:last, true) if game.afk_rounds >= Game::AFK_ROUNDS_THRESHOLD

    self.votes_change = {}

    move_to_results

    true
  end

  def time_for_results?
    vote_stage? && votes_finished?
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

  def choose_lead 
    self.user_id = game.choose_lead.id
  end

  def lead
    user
  end

  def game_is_ready
     errors.add(:game_id, "must have enough players") unless game.ready_to_play?
  end

  def max_rounds_achieved?
    return false if game.max_rounds.nil?

    game.rounds.count + 1 >= game.max_rounds # one being this new round
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

  def max_points_achieved?(user)
    return false if game.max_points.nil?

    user.current_score >= game.max_points
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

  def truncate_setup
    return if setup.length < Joke::SETUP_TRUNCATE_LENGTH

    string = setup.dup

    str_modified = if !string.end_with?(*%w[. ! ?])
                     string.concat(".")
                     true
                   end

    sentences = string.scan(/[^\.!?]+[\.!?:# ]/).map(&:strip)
    last_sentence = sentences.pop
    last_sentence.slice!(-1) if str_modified

    self.setup_short = if last_sentence.length > Joke::SETUP_TRUNCATE_LENGTH
      shorter_sentence = []

      last_sentence.split(" ").reverse.inject(0) do |sum, word|
        length = sum + word.length
        length > Joke::SETUP_TRUNCATE_LENGTH ? break : shorter_sentence << word
        length
      end

      if shorter_sentence.none?
        shorter_sentence << last_sentence.slice(-Joke::SETUP_TRUNCATE_LENGTH..-1)
      else 
        shorter_sentence.reverse
      end.join(" ")
    else
      last_sentence
    end
  end
end
