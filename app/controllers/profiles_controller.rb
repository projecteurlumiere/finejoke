class ProfilesController < ApplicationController
  before_action :set_user, except: %i[show]
  before_action :authorize_user_profile!

  def show
    @user = params[:id].nil? ? set_user : User.find(params[:id])
    @title_vars = { username: @user.username }
    
    set_jokes

    respond_to do |format|
      if @action.nil?
        format.html
      else
        format.turbo_stream
      end
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def profile_params
    params.require(:user).permit(:show_jokes_allowed, :show_awards_allowed)
  end

  def set_user
    @user = current_or_guest_user
  end

  def authorize_user_profile!
    authorize @user || User, policy_class: ProfilePolicy
  end

  def set_jokes
    @jokes = process_joke_params
  end

  def process_joke_params
    set_turbo_action
    return if @action.nil?
    return unless @user.show_jokes_allowed?

    property = set_property
    ordered_property = set_order(property)
    
    ordered_property.page(params[:page])
  end

  def set_turbo_action
    @action = case params[:turbo_action]
              when "replace"
                :replace
              when "append"
                :append
              end
  end

  def set_property
    case params[:property]
    when "finished_jokes"
      @user.finished_jokes
    when "started_jokes"
      @user.started_jokes
    else 
      params[:property] = nil
      @user.jokes
    end.left_outer_joins(:game).where(locale: I18n.locale)
                               .where("games.id IS NULL OR games.private = FALSE")
  end

  def set_order(property)
    case params[:order_by]
    when "n_votes"
      property.order(n_votes: :desc)
    when "created_at"
      property.order(created_at: :desc)
    else
      params[:order_by] = nil
      property
    end
  end
end
