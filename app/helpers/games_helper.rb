module GamesHelper
  def game_data_attributes(game)
    { 
      max_players: game.max_players,
      max_round_time: game.max_round_time,
      max_rounds: game.max_rounds,
      max_points: game.max_points,
    }
  end
end
