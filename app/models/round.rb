class Round < ApplicationRecord
  belongs_to :game
  belongs_to :user
  
  has_many :jokes

  enum stage: %i[setup punchline vote], _suffix: true

  after_update ->{ self.game.touch }
end
