class GamesController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :welcome_new_guest, if: :new_guest?, only: %i[ index show show_rules join ]
  before_action :set_game, only: %i[ show destroy ]
  before_action :authorize_game!, only: %i[ index show destroy ]


  # GET /games or /games.json
  def index
    @game = Game.new

    @games = Game.order(created_at: :desc).all
    # clean_up_games
  end

  # joins game
  def show
    redirect_to games_path unless user_can_view?
  end

  # new game form
  def new
    @game = Game.new
    authorize_game!
  end

  # creates game
  def create
    @game = Game.new(game_params)
    authorize_game!

    respond_to do |format|
      if create_game
        flash[:notice] = "Игра создана"
        format.turbo_stream { turbo_redirect_to game_path(@game) }
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1 or /games/1.json
  def destroy
    @game.destroy!

    respond_to do |format|
      format.html { redirect_to games_url, notice: "Game was successfully destroyed." }
    end
  end

  def join
    @game = Game.includes(:users).find(params[:game_id])
    
    skip_authorization and redirect_to game_path(@game) and return if @game.users.include?(current_or_guest_user)

    authorize_game!

    if @game.add_user(current_or_guest_user)
      redirect_to game_path(@game), notice: "You have joined the game"
    else
      redirect_to games_path, alert: "Something went wrong"
    end
  end

  def leave # game
    @game = Game.includes(:users).find(params[:game_id])
    skip_authorization and redirect_to games_path and return if @game.users.exclude?(current_or_guest_user)

    authorize_game!

    if @game.remove_user(current_or_guest_user)
      # disconnect_cable if params[:cable] == "disconnect"
      respond_to do |format|
        format.turbo_stream { render :leave, formats: %i[turbo_stream] }
      end
    else
      flash.now[:alert] = "Something went wrong"
      respond_to do |format|
        format.turbo_stream { render_turbo_flash }
      end
    end
  end

  def kick
    @game = Game.includes(:users).find(params[:game_id])
    @user = User.find_by(id: params[:user_id])
    authorize_game!

    if @user && @game.kick_user(@user)
      flash.now[:notice] = "User was kicked"
      respond_to do |format|
        format.turbo_stream { render_turbo_flash(status: :ok) }
      end
    else
      flash.now[:alert] = "User was not kicked"
      respond_to do |format|
        format.turbo_stream { render_turbo_flash }
      end
    end
  end

  # when there's no current round  
  def show_rules
    @game = Game.find(params[:game_id])
    authorize_game!

    render "rounds/show", layout: false, formats: %i[turbo_stream], locals: { game: @game, round: nil }
  end

  private

  def no_authentication_required?
    action_name == "index"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.includes(:users).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def game_params
    params.require(:game).permit(:name, :viewable, :max_players, :max_rounds, :max_round_time, :max_points)
  end

  def create_game
    @game.add_user(current_or_guest_user, is_host: true)
  end

  def authorize_game!
    authorize @game || Game
  end

  def user_can_view?
    user_game = current_or_guest_user.game

    return true if user_game.nil? || user_game == @game

    if user_game != @game
      flash[:alert] = "You have already joined another game"
    elsif !@game.joinable?(by: current_or_guest_user)
      flash[:alert] = "Game cannot be joined"
    end

    false
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
