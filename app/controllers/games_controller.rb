class GamesController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :verify_turbo_stream_format, only: %i[create kick show_rules]
  before_action :set_game, only: %i[ show ]
  before_action :authorize_game!, only: %i[ index show leave game_over]

  # GET /games
  def index
    @games = Game.where(private: false, locale: I18n.locale)
                 .where.not(status: :finished)
                 .order(n_players: :desc, created_at: :desc)
                 .all

    if turbo_frame_request?
      render partial: "games/catalogue"
    else
      @game = Game.new
      render :index
    end
  end

  def show
    unless user_can_view?
      flash[:alert] = t(:".cannot_show_game")
      redirect_to games_path
    end

    @title_vars = { game_name: @game.name }
  end
  
  # creates game
  def create
    @game = Game.new(locale: current_or_guest_user.locale, **game_params)
    authorize_game!

    if create_game
      flash[:notice] =  @game.create_with_virtual_host ? flash_about_virtual_host : t(:".game_created")
      turbo_redirect_to game_path(@game)
    else
      flash.now[:alert] = t(:".game_not_created")
      render partial: "games/form", formats: [:turbo_stream], status: :unprocessable_entity
    end
  end

  def join
    @game = Game.includes(:users).find(params[:game_id])
    
    skip_authorization and redirect_to(game_path(@game)) and return if @game.users.include?(current_or_guest_user)

    with_custom_pundit_error_message { authorize_game! }

    if @game.add_user(current_or_guest_user)
      redirect_to game_path(@game), notice: t(:".join_game")
    else
      redirect_to games_path, alert: t(:".joined_game_failed")
    end
  end

  def leave # game
    @game = Game.includes(:users).find_by(id: params[:game_id])

    if @game.nil? || @game.users.exclude?(current_or_guest_user)
      flash[:notice] = t(:".leave_game")
      redirect_to(games_path)
      return
    end 
    
    verify_turbo_stream_format

    if @game.remove_user(current_or_guest_user)
      flash[:notice] = t(:".leave_game")
      response.status = :see_other
      render :leave, formats: %i[turbo_stream] # removes turbo_stream that streams the game and then issues a redirect!
    else
      flash.now[:alert] = t(:".leave_game_failed")
      response.status = :unprocessable_entity
      render_turbo_flash
    end
  end

  def kick
    @game = Game.includes(:users).find(params[:game_id])
    @user = User.find_by(id: params[:user_id])
    authorize_game!

    if @user && @game.kick_user(@user)
      response.status = :ok
      flash.now[:notice] = t(:".kick_user")
    else
      response.status = :unprocessable_entity
      flash.now[:alert] = t(:".kick_user_failed")
    end

    render_turbo_flash
  end

  # when there's no current round
  def show_rules
    @game = Game.find(params[:game_id])
    authorize_game!

    render "rounds/show", layout: false, formats: %i[turbo_stream], locals: { game: @game, round: nil }
  end

  def game_over
    flash[:notice] = t(:".game_over")
    redirect_to games_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def game_params
    params.require(:game).permit(*%i[
      name
      private
      viewers_vote
      suggestable
      create_with_virtual_host
      max_players max_rounds max_round_time max_points
    ])
  end

  def create_game
    @game.add_user(current_or_guest_user, is_host: true)
  end

  def flash_about_virtual_host
    if @game.virtual_host 
      t(:".game_created_with_virtual_host")
    else
      t(:".game_created_without_virtual_host")
    end
  end

  def authorize_game!
    authorize @game || Game
  end

  def user_can_view?
    return true if @game.viewable?

    current_or_guest_user.game == @game

    # user_game = current_or_guest_user.game

    # return true if user_game.nil? || user_game == @game

    # if user_game != @game
    #   flash[:alert] = t(:".already_in_game")
    # elsif !@game.joinable?(by: current_or_guest_user)
    #   flash[:alert] = t(:".cannot_join_game")
    # end
  end

  def clean_up_games
    @games = @games.select do |game|
      if game.users.any?
        true
      else
        game.destroy
        false
      end 
    end
  end

  def disconnect_cable
    ActionCable.server.remote_connections.where(current_or_guest_user: current_or_guest_user).disconnect
    current_or_guest_user.update(connected: false, subscribed_to_game: false)
  end
end
