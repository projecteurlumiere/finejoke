class Vote < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :round, optional: true
  belongs_to :joke, touch: true

  validate -> { user.can_vote?(round) }

  after_create -> { user.voted!if user.playing?(round) }
  after_create -> { joke.increment!(:n_votes) }
end
