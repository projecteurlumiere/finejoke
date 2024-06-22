module RoundsHelper
  # def render_round_state(round)
  #   locals = if round.setup_stage?
  #     if current_or_guest_user.lead?
  #       { hidden: true, form: render(partial: "rounds/form", locals: { game: round.game, round: round }) }
  #     else
  #       # state (masked)
  #      { hidden: true }
  #     end
  #   elsif round.punchline_stage?
  #     if current_or_guest_user.lead?
  #       # state (masked)
  #       { hidden: true }
  #     elsif current_or_guest_user.finished_turn?
  #       # state (masked) but with joke form
  #       { hidden: true }
  #     else
  #       # state (masked)
  #       { hidden: true, form: render(partial: "jokes/form", locals: { joke: round.jokes.build }) }
  #     end 
  #   elsif round.vote_stage?
  #     if current_or_guest_user.voted?
  #       # state without vote buttons
  #      nil
  #     else
  #       # state with vote buttons
  #      { vote: true }
  #     end
  #   elsif round.results_stage?
  #     nil
  #   end

  #   round_partial(round, locals)
  # end

  # def round_partial(round, locals = nil)
  #   default_locals = { round: round }
  #   locals = locals ? locals.merge(default_locals) : default_locals

  #   render partial: "rounds/round", locals: locals
  # end

  def round_task_for(user, round)
    case @round.stage
    when "setup"
      if user.lead?
        "Придумайте завязку для самой смешной шутки в мире"
      else
        "Игрок придумывает завязку"
      end
    when "punchline"
      unless user.lead?
        "Придумайте развязку к следующей завязке"
      else
        "Другие игроки придумают развязки"
      end
    when "vote"
      unless user.voted?
        "Проголосуйте за понравившуюся шутку"
      else
        "Игроки голосуют"
      end
    when "result"
      "Наслаждайтесь результатами"
    end
  end

  def render_action_for(user, round)
    render_form_for(user, round) || 
      render_votes_for(user, round) ||
      render_results_for(user, round)
  end

  def render_form_for(user, round)
    return if user.finished_turn?

    if user.lead? && round.setup_stage?
      render partial: "rounds/form", locals: { game: round.game, round: round }
    elsif !user.lead? && round.punchline_stage?
      render partial: "jokes/form", locals: { joke: round.jokes.build }
    end
  end

  def render_votes_for(user, round)
    return unless round.vote_stage?

    render partial: "rounds/joke", collection: round.jokes, locals: { round: round, voting: !user.voted?}
  end

  def render_results_for(user, round)
    return unless round.results_stage?

    jokes = round.jokes.order(votes: :desc).to_a

    [
      render(partial: "rounds/results", locals: { joke: jokes.shift }),
      render(partial: "rounds/joke", collection: jokes, locals: { round: round, voting: false })
    ].join(" ").html_safe
   
  end
end
