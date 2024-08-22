module GamesHelper
  def game_data_attributes(game)
    { 
      max_players: game.max_players,
      max_round_time: game.max_round_time,
      max_rounds: game.max_rounds,
      max_points: game.max_points,
    }
  end

  def game_user_class(user, round)
    default_classes = %i[button]

    return default_classes if round.nil?

    color_class = if user.hot_join?
                    :slot # dim colors like in slot
                  elsif round.setup_stage? && user.lead?
                    :red
                  elsif round.punchline_stage? 
                    if user.lead? 
                      nil
                    elsif user.finished_turn?
                      :teal
                    else
                      :red
                    end
                  elsif round.vote_stage?
                    if user.voted?(round)
                      :teal
                    else
                      :red
                    end
                  end

    default_classes << color_class
    default_classes.compact.join(" ")
  end
end
