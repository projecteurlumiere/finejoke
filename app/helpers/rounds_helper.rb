module RoundsHelper
  def round_data_attributes(user, round, game)
    attributes = {
      timer_target: :timings,
      jokes_target: :state,
      game_status: game.status
    }

    attributes.merge!({
      n_rounds: round.game.n_rounds,
      stage: round.stage,
      change_scheduled_at: round.change_scheduled_at.to_f * 1000,
      change_deadline: round.change_deadline.to_f * 1000,
      user_lead: user.lead?,
      user_voted: user.voted?(round),
      user_finished_turn: user.finished_turn?
    }) if round

    attributes
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

    @setup = messages[2]

    [
      tag.h2(messages[0]),
      tag.div(tag.p(messages[1]))

    ].compact.join(" ").html_safe
  end

  def game_over_task_for(game)
    if game.winner
      [
        "#{t(".winner_is")} #{game.winner.username}",
        "#{t(".his_score_is")} #{game.winner_score}"
      ]
    else
      [
        t(".game_over"),
        t(".congratulations")
      ]
    end
  end

  def round_task_for_player(user, round)
    case round.stage.to_sym
    when :setup
      if user.lead?
        [
          t(".create_setup"),
          t(".create_setup_subheading")
        ]
      else
        [
          t(".setup_is_being_created"),
          t(".setup_is_being_created_subheading")
        ]
      end
    when :punchline
      unless user.finished_turn? || user.lead?
        [
          t(".create_punchline"),
          nil, # t(".create_punchline_subheading")
          :setup
        ]
      else
        [
          t(".punchlines_are_being_created"),
          t(".punchlines_are_being_created_subheading")
        ]
      end
    when :vote
      if user.can_vote?(round)
        [
          t(".vote_for_joke"),
          nil, # t(".vote_for_joke_subheading")
          :setup
        ]
      else
        [
          t(".players_are_voting"),
          nil, # t(".players_are_voting_subheading"),
          :setup
        ]
      end
    when :results
      [
        t(".round_results"),
        nil, # t(".round_results.subheading"),
        :setup
      ]
    end
  end

  def round_task_for_viewer(_user, round)
    case round.stage.to_sym
    when :setup
      [
        t(".viewer.setup_is_being_created"),
        t(".viewer.setup_is_being_created_subheading")
      ]

    when :punchline
      [
        t(".viewer.punchlines_are_being_created"),
        nil, # t(".viewer.punchlines_are_being_created_subheading"),
        :setup
      ]
    when :vote
      [
        t(".viewer.players_are_voting"),
        nil, # t(".viewer.players_are_voting_subheading")
        :setup
      ]
    when :results
      [
        t(".viewer.round_results"),
        nil,
        :setup
      ]
    end
  end

  def render_setup_for(round)
    # declared in round_task_for
    return unless @setup

    tag.div(class: "setup", data: { jokes_target: "setup" }) do 
      [
        tag.div(round.user.username, class: :username),
        tag.p(round.setup, class: "bubble top shadow")
      ].join(" ").html_safe
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
      render partial: "rounds/joke_form", locals: { game: round.game, round: round, joke: round.jokes.build }
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
      tag.h2(t(".rules")),
      tag.div(tag.p(t(".rules_content")), class: "rules")
    ].join(" ").html_safe
  end

  # only for host
  def render_rules_action_for(user, game)
    return unless game.host == user

    content_for(:action) do 
      button_to(t(".start"), game_rounds_path(game))
    end
  end

  def render_default_action_for(user, round, game)
    return render_join(game) if game.joinable?(by: user)
    return render_game_over_button if game.finished?

    render_wait_for(user, round, game)
  end

  def render_join(game)
    link_to(t(".join"), game_join_path(game), class: "button").html_safe
  end

  def render_game_over_button
    tag.button(t(".game_over"), class: "disabled", disabled: true).html_safe
  end

  def render_wait_for(user, round, game)
    message = user.hot_joined?(game) && !round.last? ? t(".wait_for_new_round") : t(".wait")
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
