class Joke < ApplicationRecord
  belongs_to :round, touch: true, optional: true
  belongs_to :user
  belongs_to :punchline_author, class_name: "User"

  before_create :compose_full_joke
  after_create :finish_user_turn
  after_create -> { round.touch if round&.turns_finished? }
  # after_commit { self.round.touch }

  def compose_full_joke
    self.text = [setup, punchline].join(" ")
  end

  def finish_user_turn
    self.user.finished_turn!
  end

  def register_vote(by:) # user
    user = by
    ActiveRecord::Base.transaction do
      self.increment(:votes) 
      self.save && user.voted!
    end
  end
end
