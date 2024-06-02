class Round < ApplicationRecord
  belongs_to :game

  belongs_to :user, optional: true
   validates :user_id, presence: true, unless: :new_record?
  
    has_many :jokes, dependent: :nullify

  enum stage: %i[setup punchline vote results], _suffix: true

  # tidying up and choosing lead player:
  before_create :reset_players, :choose_lead
  before_create :set_last, if: :max_rounds_achieved?
   after_create -> { game.touch }
  # when lead updated round with setup:
   after_update :move_to_punchline, if: %i[setup_stage? setup?]
  # called every time joke is created:
    after_touch :move_to_vote, if: %i[punchline_stage? turns_finished?]
    after_touch :count_votes, :move_to_results, if: %i[vote_stage? votes_finished?]
    after_touch :schedule_next_round, if: :results_stage?, unless: :last?
    after_touch -> { game.touch }

  def reset_players
    game.reset_players
  end

  def choose_lead 
    self.user_id = game.choose_lead.id
  end

  def max_rounds_achieved?
    return false if game.max_rounds.nil?

    game.max_rounds == game.rounds.count + 1 # one being this new round
  end

  def set_last
    self.last = true
  end

  def move_to_punchline
    user.update_attribute(:finished_turn, true)
    punchline_stage!
    game.touch
  end

  def move_to_vote
    vote_stage!
  end

  def count_votes
    jokes.each do |joke|
      author = joke.user
      author.current_score += joke.votes
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
  end

  def schedule_next_round
    CreateNewRoundJob.set(wait: 1.second).perform_later(game)
  end

  def turns_finished?
    game.users.find_by(finished_turn: false) ? false : true
  end

  def votes_finished?
    game.users.find_by(voted: false) ? false : true
  end
end
