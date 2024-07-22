module RoundsHelper
  def round_data_attributes(round)
    return nil if round.nil?

    {
      game_status: round.game.status,
      n_rounds: round.game.n_rounds,
      stage: round.stage,
    }
  end

  def round_task_for(user, round, game)
    messages = if round.nil?
                 return render_rules_for(game)
               elsif user.playing?(game)
                 round_task_for_player(user, round)
               else
                 round_task_for_viewer(user, round)
               end

    raise "why is it nil?" if messages.nil?

    [
      tag.h2(messages[0]),
      tag.p(messages[1])
    ].join(" ").html_safe
  end

  def round_task_for_player(user, round)
    case round.stage.to_sym
    when :setup
      if user.lead?
        [
          "Придумайте завязку",
          "С чего бы могла начаться хорошая шутка?"
        ]
      else
        [
          "Игрок придумывает завязку",
          "Надо подождать"
        ]
      end
    when :punchline
      unless user.lead?
        [
          "Придумайте развязку к следующей завязке",
          round.setup
        ]
      else
        [
          "Другие игроки придумывают развязки",
          "Надо подождать"
        ]
      end
    when :vote
      if user.can_vote?(round)
        [
          "Выберите лучший ответ",
          round.setup
        ]
      else
        [
          "Игроки голосуют",
          "Надо подождать"
        ]
      end
    when :results
      [
        "Наслаждайтесь результатами",
        "Новый раунд скоро начнётся"
      ]
    end
  end

  def round_task_for_viewer(_user, round)
    case round.stage.to_sym
    when :setup
      [
        "Игрок придумывает завязку",
        "Ждём, что она будет забавной"
      ]

    when :punchline
      [
        "Игроки придумывают развязки к завязке:",
        round.setup
      ]
    when :vote
      [
        "Игроки голосуют",
        "Надо подождать"
      ]
    when :results
      [
        "Наслаждайтесь результатами",
        "Новый раунд скоро начнётся"
      ]
    end
  end

  def render_input_for(user, round, game)
    return render_rules_action_for(user, game) if round.nil?

    render_turns_form_for(user, round) || 
      render_votes_form_for(user, round) ||
      render_results_for(user, round)
  end

  def render_turns_form_for(user, round)
    return unless user.playing?(round)
    return if user.finished_turn?

    if user.lead? && round.setup_stage?
      render partial: "rounds/setup_form", locals: { game: round.game, round: round }
    elsif !user.lead? && round.punchline_stage?
      render partial: "jokes/form", locals: { game: round.game, round: round, joke: round.jokes.build }
    end
  end

  def render_votes_form_for(user, round)
    return unless round.vote_stage?

    jokes = round.jokes.order("RANDOM()")

    render partial: "rounds/vote", locals: { round: round, jokes: jokes, user: user }
  end

  def render_results_for(user, round)
    return unless round.results_stage?

    jokes = round.jokes.order(n_votes: :desc)

    render partial: "rounds/vote", locals: { round: round, jokes: jokes, user: user }   
  end
  
  def render_rules_for(_game)
    [
      tag.h2("Правила"),
      tag.p("Какие-то правила")
    ].join(" ").html_safe
  end

  def render_rules_action_for(user, game)
    content_for(:action) do 
      if game.host == user
        button_to("Start game", game_rounds_path(game))
      else 
        render_wait_or_join_for(user, game)
      end
    end
  end

  def render_wait_or_join_for(user, game)
    if game.joinable?(by: user)
      render_join(game)
    elsif user.hot_joined?(game)
      tag.button("Вы в игре со следующего раунда", class: "disabled", disabled: true).html_safe 
    else
      tag.button("Ждём", class: "disabled", disabled: true).html_safe
    end
  end

  def render_join(game)
    link_to("Присоединиться", game_join_path(game), class: "button").html_safe
  end
end
