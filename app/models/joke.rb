class Joke < ApplicationRecord
  belongs_to :round, touch: true, optional: true
  belongs_to :user

  after_create :finish_user_turn
  before_update :compose_full_joke
  # after_commit { self.round.touch }

  def compose_full_joke
    self.text = [round.setup, punchline].join(" ")
  end

  def finish_user_turn
    self.user.update_attribute(:finished_turn, true)
  end

  def register_vote(by:) # user
    ActiveRecord::Base.transaction do
      self.increment(:votes) 
      self.save && by.update_attribute(:voted, true)
    end
  end
end
