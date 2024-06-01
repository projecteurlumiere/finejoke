class Joke < ApplicationRecord
  belongs_to :round, optional: true
  belongs_to :user

  after_create { self.user.update_attribute(:finished_turn, true) }
  after_create { self.round.touch }
end
