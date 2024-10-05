class SuggestionsController < ApplicationController
  before_action :verify_turbo_frame_format, only: %i[show_quota]
  before_action :verify_turbo_stream_format, except: %i[show_quota]
  before_action :set_suggestion, except: %i[show_quota]
  before_action :authorize_suggestion!
  before_action :authenticate_for_ai, if: :authentication_required_for_ai?, except: %i[show_quota]

  def suggest_setup
    if @suggestion.save
      flash.now[:notice] = t(:".setup_suggested")
    else
      flash.now[:alert] = t(:".setup_not_suggested")
      render_turbo_flash
    end
  end

  def suggest_punchline
    if @suggestion.save
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
  end

  def suggestion_params
    params.require(:suggestion).permit(:user_input, :game_id, :round_id, :target)
  end
  
  def authorize_suggestion!
    authorize(@suggestion || Suggestion)
  end

  # this is done because there is no neat way to specify custom error messages from
  # pundit's poolicies
  def authenticate_for_ai
    return if current_user

    flash.now[:alert] = t :"devise.failure.unauthenticated"
    raise Pundit::NotAuthorizedError
  end
end
