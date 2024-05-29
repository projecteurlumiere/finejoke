class Game < ApplicationRecord
  has_many :users # players 
  has_many :rounds

  after_create -> { broadcast_replace_to "lobby", partial: "games/list", locals: { games: Game.all }, target: "games" }
end
