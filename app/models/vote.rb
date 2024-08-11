class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :round
  belongs_to :joke, touch: true

  validate -> { user.can_vote?(round) }

  after_create -> { user.update_attribute(:voted, true) if user.playing?(round) }
  after_create -> { joke.increment!(:n_votes) }
  after_create -> { user.broadcast_turn_finished if user.playing?(round) }
end
