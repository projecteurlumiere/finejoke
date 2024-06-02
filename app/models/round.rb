class Round < ApplicationRecord
  belongs_to :game

  belongs_to :user, optional: true
   validates :user_id, presence: true, unless: :new_record?
  
    has_many :jokes, dependent: :nullify

  enum stage: %i[setup punchline vote results], _suffix: true

  before_create :reset_players, :choose_lead
   after_update :move_to_punchline, if: %i[setup_stage? setup?]
    after_touch :move_to_vote, if: %i[punchline_stage? turns_finished?]
    after_touch :count_votes, :move_to_results, if: %i[vote_stage? votes_finished?]
    after_touch -> { self.game.touch }

  def reset_players
    self.game.reset_players
  end

  def choose_lead 
    self.user_id = self.game.choose_lead.id
    self.game.touch
  end

  def move_to_punchline
    self.user.update_attribute(:finished_turn, true)
    self.punchline_stage!
    self.game.touch
  end

  def move_to_vote
    self.vote_stage!
  end

  def count_votes
    self.jokes.each do |joke|
      author = joke.user
      author.current_score += joke.votes
      author.save
    end
  end

  def move_to_results
    self.results_stage!
    CreateNewRoundJob.set(wait: 1.second).perform_later(self.game)
  end

  def punchline_over?
    self.game.users
  end

  def turns_finished?
    self.game.users.find_by(finished_turn: false) ? false : true
  end

  def votes_finished?
    self.game.users.find_by(voted: false) ? false : true
  end
end
