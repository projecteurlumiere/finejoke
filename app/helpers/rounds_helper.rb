module RoundsHelper
  def render_round_state(round)
    locals = if round.setup_stage?
      if current_or_guest_user.lead?
        { hidden: true, form: render(partial: "rounds/form", locals: { game: round.game, round: round }) }
      else
        # state (masked)
       { hidden: true }
      end
    elsif round.punchline_stage?
      if current_or_guest_user.lead?
        # state (masked)
        { hidden: true }
      elsif current_or_guest_user.finished_turn?
        # state (masked) but with joke form
        { hidden: true }
      else
        # state (masked)
        { hidden: true, form: render(partial: "jokes/form", locals: { joke: round.jokes.build }) }
      end 
    elsif round.vote_stage?
      if current_or_guest_user.voted?
        # state without vote buttons
       nil
      else
        # state with vote buttons
       { vote: true }
      end
    elsif round.results_stage?
      nil
    end

    round_partial(round, locals)
  end

  def round_partial(round, locals = nil)
    default_locals = { round: round }
    locals = locals ? locals.merge(default_locals) : default_locals

    render partial: "rounds/round", locals: locals
  end
end
