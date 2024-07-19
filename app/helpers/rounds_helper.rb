module RoundsHelper
  def round_data_attributes(round)
    return nil if round.nil?

    {
      game_status: round.game.status,
      n_rounds: round.game.n_rounds,
      stage: round.stage,
    }
  end

  def round_task_for(user, round)
    return render_rules_for(user) if round.nil?

    array = case round.stage.to_sym
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
      unless user.voted?
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

    return if array.nil?

    [
      tag.h2(array[0]),
      tag.p(array[1])
    ].join("").html_safe
  end

  def render_input_for(user, round)
    return render_rules_action_for(user) if round.nil?

    render_turns_form_for(user, round) || 
      render_votes_form_for(user, round) ||
      render_results_for(user, round)
  end

  def render_turns_form_for(user, round)
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

    render partial: "rounds/voting", locals: { round: round, jokes: jokes, user: user}
  end

  def render_results_for(user, round)
    return unless round.results_stage?

    jokes = round.jokes.order(votes: :desc)

    render partial: "rounds/voting", locals: { round: round, jokes: jokes, user: user }   
  end
  
  def render_rules_for(user)
    [
      tag.h2("Правила"),
      tag.p("Какие-то правила")
    ].join(" ").html_safe
  end

  def render_rules_action_for(user)
    content_for(:action) do 
      if user.host?
        button_to("Start game", game_rounds_path(user.game))
      else 
        render_wait
      end
    end
  end

  def render_wait
    tag.button("Ждём", class: "disabled", disabled: true).html_safe
  end
end
