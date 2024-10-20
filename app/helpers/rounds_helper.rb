module RoundsHelper
  def round_data_attributes(user, round, game)
    return @attributes if @attributes

    @attributes = {
      timer_target: :timings,
      jokes_target: :state,
      game_id: game.id,
      game_status: game.status,
      user_playing: user.playing?(game),
      hot_join: user.hot_join?,
      user_host: game.host_id == user.id,
      force_showing_rules: round.nil? && game.ongoing?
    }

    @attributes.merge!({
      round_id: round.id,
      n_rounds: game.n_rounds,
      stage: round.stage,
      change_scheduled_at: round.change_scheduled_at.to_f * 1000,
      change_deadline: round.change_deadline.to_f * 1000,
    }) if round

    @attributes.merge!({
      user_lead: user.lead?,
      user_voted: user.voted?(round),
      user_finished_turn: user.finished_turn?,
      user_wants_to_skip_results: user.wants_to_skip_results?
    }) if user.playing?(round)

    @attributes
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

    @render_setup = messages[2]

    [
      tag.h2(messages[0]),
      tag.div(tag.p(messages[1]))

    ].compact.join(" ").html_safe
  end

  def game_over_task_for(game)
    if game.winner
      [
        "#{t(:".winner_is")} #{game.winner.username}",
        "#{t(:".his_score_is")} <span class='red'>#{game.winner_score}</span>".html_safe
      ]
    else
      [
        t(:".game_over"),
        t(:".congratulations")
      ]
    end
  end

  def round_task_for_player(user, round)
    case round.stage.to_sym
    when :setup
      if user.lead?
        [
          t(:".create_setup"),
          t(:".create_setup_subheading")
        ]
      else
        [
          t(:".setup_is_being_created"),
          t(:".setup_is_being_created_subheading")
        ]
      end
    when :punchline
      unless user.finished_turn? || user.lead?
        [
          t(:".create_punchline"),
          nil, # t(:".create_punchline_subheading")
          :setup
        ]
      else
        [
          t(:".punchlines_are_being_created"),
          t(:".punchlines_are_being_created_subheading")
        ]
      end
    when :vote
      if user.can_vote?(round)
        [
          t(:".vote_for_joke"),
          nil, # t(:".vote_for_joke_subheading")
          :setup
        ]
      else
        [
          t(:".players_are_voting"),
          nil, # t(:".players_are_voting_subheading"),
          :setup
        ]
      end
    when :results
      [
        t(:".round_results"),
        nil, # t(:".round_results.subheading"),
        :setup
      ]
    end
  end

  def round_task_for_viewer(user, round)
    case round.stage.to_sym
    when :setup
      [
        t(:".viewer.setup_is_being_created"),
        t(:".viewer.setup_is_being_created_subheading")
      ]

    when :punchline
      [
        t(:".viewer.punchlines_are_being_created"),
        nil, # t(:".viewer.punchlines_are_being_created_subheading"),
        :setup
      ]
    when :vote
      [
        user.can_vote?(round) ? t(:".viewer.vote_for_joke") : t(:".viewer.players_are_voting"),
        nil, # t(:".viewer.players_are_voting_subheading")
        :setup
      ]
    when :results
      [
        t(:".viewer.round_results"),
        nil,
        :setup
      ]
    end
  end

  def render_setup_for(round)
    # declared in round_task_for
    return unless @render_setup

    username = round.setup_randomized? ? t(:".anon_host") : round.lead.username

    setup = round.setup || t(:"rounds.no_setup.mock")
    setup_short = round.setup_short

    # should excavate this into separate a view template
    setup_p = tag.p(class: "bubble top shadow", 
                    data: {
                      action: "mouseup->setup#toggleView"
                    }) do
      [
        tag.span(setup, 
          data: { setup_target: :long },
          class: ("hidden" if !round.punchline_stage? && setup_short)),
        (tag.span("<...> #{setup_short}", 
          data: { setup_target: :short },
          class: ("hidden" if round.punchline_stage?)) if setup_short)
      ].compact.join(" ").html_safe
    end

    tag.div(class: "setup", data: { controller: "setup", jokes_target: "setup" }) do
      [
        tag.div(username, class: :username),
        setup_p
      ].join(" ").html_safe
    end
  end

  def render_input_for(user, round, game)
    return render_game_over_for(user, round, game) if game.finished?
    return render_rules_action_for(user, game) if round.nil?

    render_turns_form_for(user, round, game) || 
      render_votes_form_for(user, round, game) ||
      render_results_for(user, round, game)
  end

  # only for players
  def render_turns_form_for(user, round, game)
    return unless user.playing?(round)
    return if user.finished_turn?

    if user.lead? && round.setup_stage?
      render partial: "rounds/form", 
        locals: { 
          game:, 
          round:,
          model: round,
          url: game_round_path(game, round),
          method: :patch,
          id: :"new-setup",
          text_for: :setup,
          suggestion_quota: user.suggestion_quota
      }
    elsif !user.lead? && round.punchline_stage?
      render partial: "rounds/form", 
        locals: { 
          game:, 
          round:,
          model: round.jokes.build, 
          url: game_round_jokes_path(game, round),
          method: :create,
          id: :"new-joke",
          text_for: :punchline,
          suggestion_quota: user.suggestion_quota
        }
    end
  end

  # for players and viewers and those who hot joined if voting is allowed for viewers 
  def render_votes_form_for(user, round, game)
    return unless round.vote_stage?

    jokes = round.jokes.order("RANDOM()")

    render partial: "rounds/jokes_container", locals: { user:, round:, game:, jokes:}
  end

  # for everyone
  def render_results_for(user, round, game)
    return unless round.results_stage?

    jokes = round.jokes.includes(:user).order(n_votes: :desc)
    render partial: "rounds/jokes_container", locals: { user:, round:, game:, jokes:}
  end

  def render_game_over_for(user, round, game)
    jokes = game.jokes.includes(:user, setup_model: [:user]).order(n_votes: :desc).limit(10)
    render partial: "rounds/jokes_container", locals: { user:, round:, game:, jokes:}
  end
  
  # for everyone
  def render_rules_for(game)
    render partial: "games/rules", locals: { game: }
  end

  # only for host
  def render_rules_action_for(user, game)
    return if game.host != user || game.ongoing?

    content_for(:action) do 
      button_to(t(:".start"), game_rounds_path(game))
    end
  end

  def render_default_action_for(user, round, game)
    return render_exit_from_rules(game) if @attributes[:force_showing_rules]
    return render_game_over_button if game.finished?
    return render_join(game) if game.joinable?(by: user)
    return render_skip_results(game, round) if round&.results_stage? && user.playing?(round) && !user.wants_to_skip_results?

    render_wait_for(user, round, game)
  end

  def render_exit_from_rules(game)
    button_to(t(:".back"), game_rounds_current_path(game), method: :get, 
      data: { 
        action: "click->round-refresh#stopForceShowingRules",
        turbo_stream: true
      }) 
  end

  def render_game_over_button
    tag.button(t(:".game_over"), class: "disabled", disabled: true).html_safe
  end

  def render_join(game)
    button_to(t(:".join"), game_join_path(game), class: "button").html_safe
  end

  def render_skip_results(game, round)
    button_to(t(:".skip_results"), 
      game_round_skip_results_path(game, round),
      form: {
          data: { 
          controller: "skip-results",
          action: "turbo:submit-end->skip-results#disable",
          disabled_text: t(:".wait")
        }
      }).html_safe
  end

  def render_wait_for(user, round, game)
    message_key = user.hot_joined?(game) && round && !round.last? ? :".wait_for_new_round" : :".wait"
    tag.button(t(message_key), 
               class: "disabled", 
               style: ("white-space: wrap" if message_key == :".wait_for_new_round"),
               disabled: true).html_safe
  end
end
