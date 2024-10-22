module GamesHelper
  def sound_controller_values
    {
      sound_turn_url_value: asset_path("turn.mp3"),
      sound_bubble_url_value: asset_path("bubble.mp3")
    }
  end

  def game_data_attributes(game)
    { 
      max_players: game.max_players,
      max_round_time: game.max_round_time,
      max_rounds: game.max_rounds,
      max_points: game.max_points,
    }
  end

  def game_user_class(user, round, voted)
    default_classes = %i[button]

    return default_classes if round.nil?

    color_class = if user.hot_join?
                    :slot # dim colors like in slot
                  elsif round.setup_stage? && user.lead?
                    :"accent-alert"
                  elsif round.punchline_stage? 
                    if user.lead? 
                      nil
                    elsif user.finished_turn?
                      nil
                    else
                      :"accent-alert"
                    end
                  elsif round.vote_stage?
                    if voted
                      nil
                    else
                      :"accent-alert"
                    end
                  end

    default_classes << color_class
    default_classes.compact.join(" ")
  end

  def hide_in_mobile_when(action)
    "hidden-when-mobile" if action_name == action
  end
end