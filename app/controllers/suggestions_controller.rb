class SuggestionsController < ApplicationController
  before_action :set_suggestion
  before_action :authorize_suggestion!

  def suggest_setup
    if @suggestion.generate
      flash.now[:notice] = t(:".setup_suggested")
    else
      flash.now[:alert] = t(:".setup_not_suggested")
      render_turbo_flash
    end
  end

  def suggest_punchline
    if @suggestion.generate
      flash.now[:notice] = t(:".punchline_suggested")
    else
      flash.now[:alert] = t(:".punchline_not_suggested")
      render_turbo_flash
    end
  end

  private

  def set_suggestion
    @suggestion = Suggestion.create(user: current_or_guest_user, **suggestion_params)
  end

  def suggestion_params
    params.require(:suggestion).permit(:user_input, :game_id, :round_id, :target)
  end
  
  def authorize_suggestion!
    authorize(@suggestion || Suggestion)
  end
end
