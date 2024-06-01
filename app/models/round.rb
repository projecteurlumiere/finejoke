class Round < ApplicationRecord
  belongs_to :game
  belongs_to :user
  
  has_many :jokes, dependent: :nullify

  enum stage: %i[setup punchline vote], _suffix: true

  after_create :reset_turns
  after_update :move_to_punchline, if: %i[setup_stage? setup?]
  after_update :move_to_vote, if: %i[punchline_stage? turns_finished?]

  def reset_turns
    self.game.reset_turns
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

  def punchline_over?
    self.game.users
  end

  def turns_finished?
    self.game.users.find_by(finished_turn: false) ? false : true
  end
end
