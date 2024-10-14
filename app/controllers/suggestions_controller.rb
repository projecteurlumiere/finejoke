class SuggestionsController < ApplicationController
  before_action :verify_turbo_frame_format, only: %i[show_quota]
  before_action :verify_turbo_stream_format, except: %i[show_quota]
  before_action :authorize_suggestion!, only: %i[show_quota]
# before_action :authenticate_for_ai, if: :authentication_required_for_ai?, except: %i[show_quota]
  before_action :set_suggestion, except: %i[show_quota]

  def suggest_setup
    if @suggestion.output
      flash.now[:notice] = t(:".setup_suggested")
    else
      flash.now[:alert] = t(:".setup_not_suggested")
      render_turbo_flash
    end
  end

  def suggest_punchline
    if @suggestion.output
      flash.now[:notice] = t(:".punchline_suggested")
    else
      flash.now[:alert] = t(:".punchline_not_suggested")
      render_turbo_flash
    end
  end

  def show_quota
    render :show_quota, layout: false, locals: { quota: current_or_guest_user.suggestion_quota }
  end

  private

  def set_suggestion
    @suggestion = Suggestion.new(user: current_or_guest_user, **suggestion_params)
    authorize_suggestion!
    return if @suggestion.save

    @suggestion.reuse_previous_suggestion
  end

  def suggestion_params
    params.require(:suggestion).permit(:user_input, :game_id, :round_id, :target)
  end
  
  def authorize_suggestion!
    with_custom_pundit_error_message { authorize(@suggestion || Suggestion) }
  end
end
