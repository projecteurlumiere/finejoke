module RoundsHelper
  def round_data_attributes(round)
    return nil if round.nil?

    {
      game_status: round.game.status,
      n_rounds: round.game.n_rounds,
      stage: round.stage,
      change_scheduled_at: round.change_scheduled_at.to_f * 1000,
      change_deadline: round.change_deadline.to_f * 1000,
      timer_target: :timings
    }
  end

  def round_task_for(user, round, game)
    messages = if game.finished?
                 game_over_task_for(game)
               elsif round.nil?
                 return render_rules_for(game)
               elsif user.playing?(game)
                 round_task_for_player(user, round)
               else
                 round_task_for_viewer(user, round)
               end

    raise "why is it nil?" if messages.nil?

    [
      tag.h2(messages[0]),
      tag.div(tag.p(messages[1], class: @p_class))
    ].join(" ").html_safe
  end

  def game_over_task_for(game)
    if game.winner
      [
        "Победил #{game.winner.username}",
        "Его счёт #{game.winner_score}"
      ]
    else
      [
        "Игра окончена",
        "Поздравляем!"
      ]
    end
  end

  def round_task_for_player(user, round)
    case round.stage.to_sym
    when :setup
      if user.lead?
        [
          "Придумайте завязку",
          "Как начать хорошую шутку?"
        ]
      else
        [
          "Игрок придумывает завязку",
          "Надо подождать"
        ]
      end
    when :punchline
      unless user.lead?
        @p_class = :setup
        [
          "Придумайте смешную развязку",
          round.setup
        ]
      else
        [
          "Другие игроки придумывают развязки",
          "Надо подождать"
        ]
      end
    when :vote
      @p_class = :setup
      if user.can_vote?(round)
        [
          "Выберите лучший ответ",
          ""
        ]
      else
        [
          "Игроки голосуют",
          ""
        ]
      end
    when :results
      [
        "Результаты раунда",
        ""
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
      @p_class = :setup
      [
        "Игроки придумывают развязки к завязке:",
        round.setup
      ]
    when :vote
      @p_class = :setup
      [
        "Игроки голосуют",
        round.setup
      ]
    when :results
      [
        "Результаты раунда",
        ""
      ]
    end
  end

  def render_input_for(user, round, game)
    return render_game_over_for(user, round, game) if game.finished?
    return render_rules_action_for(user, game) if round.nil?

    render_turns_form_for(user, round) || 
      render_votes_form_for(user, round) ||
      render_results_for(user, round)
  end

  # only for players
  def render_turns_form_for(user, round)
    return unless user.playing?(round)
    return if user.finished_turn?

    if user.lead? && round.setup_stage?
      render partial: "rounds/setup_form", locals: { game: round.game, round: round }
    elsif !user.lead? && round.punchline_stage?
      render partial: "jokes/form", locals: { game: round.game, round: round, joke: round.jokes.build }
    end
  end

  # for players and viewers and those who hot joined if voting is allowed for viewers 
  def render_votes_form_for(user, round)
    return unless round.vote_stage?

    jokes = round.jokes.order("RANDOM()")

    render partial: "rounds/vote", locals: { round: round, jokes: jokes, user: user }
  end

  # for everyone
  def render_results_for(user, round)
    return unless round.results_stage?

    jokes = round.jokes.order(n_votes: :desc)
    render partial: "rounds/vote", locals: { round: round, jokes: jokes, user: user }
  end

  def render_game_over_for(user, round, game)
    jokes = game.jokes.order(n_votes: :desc).limit(10)
    render partial: "rounds/vote", locals: { round: round, jokes: jokes, user: user }
  end
  
  # for everyone
  def render_rules_for(_game)
    [
      tag.h2("Правила"),
      tag.div(tag.p("Какие-то правила"), class: "rules")
    ].join(" ").html_safe
  end

  # only for host
  def render_rules_action_for(user, game)
    return unless game.host == user

    content_for(:action) do 
      button_to("Старт!", game_rounds_path(game))
    end
  end

  def render_default_action_for(user, round, game)
    return render_join(game) if game.joinable?(by: user)
    return render_game_over_button if game.finished?

    render_wait_for(user, round, game)
  end

  def render_join(game)
    link_to("Присоединиться", game_join_path(game), class: "button").html_safe
  end

  def render_game_over_button
    tag.button("Игра окончена", class: "disabled", disabled: true).html_safe
  end

  def render_wait_for(user, round, game)
    message = user.hot_joined?(game) && !round.last? ? "Ждём новый раунд" : "Ждём"
    tag.button(message, class: "disabled", disabled: true).html_safe
  end

  def format_shorter(string)
    str_modified = if string.end_with?(*%w[. ! ?])
                     string.concat(".")
                     true
                   end
    
    sentences = string.scan(/[^\.!?]+[\.!?]/).map(&:strip)
    last_sentence = sentences.pop
    last_sentence.slice!(0, -1) if str_modified

    [tag.span(sentences.join(" "), class: "hidden"), tag.span([tag.span("..."), last_sentence].join(" ").html_safe)].join(" ") 
  end
end
