class GamesController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :welcome_new_guest, if: :new_guest?, only: %i[ index show show_rules join ]
  before_action :set_game, only: %i[ show destroy ]
  before_action :authorize_game!, only: %i[ index show destroy ]

  # GET /games
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

    if create_game
      flash[:notice] = "Игра создана"
      turbo_redirect_to game_path(@game)
    else
      flash.now[:alert] = "Игра не была создана"
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /games/1
  def destroy
    @game.destroy!

    redirect_to games_url, notice: "Игра удалена"
  end

  def join
    @game = Game.includes(:users).find(params[:game_id])
    
    skip_authorization and redirect_to(game_path(@game)) and return if @game.users.include?(current_or_guest_user)

    authorize_game!

    if @game.add_user(current_or_guest_user)
      redirect_to game_path(@game), notice: "Вы присоединились к игре"
    else
      redirect_to games_path, alert: "Не получилось присоединиться к игре"
    end
  end

  def leave # game
    @game = Game.includes(:users).find(params[:game_id])
    skip_authorization and redirect_to(games_path) and return if @game.users.exclude?(current_or_guest_user)

    authorize_game!

    if @game.remove_user(current_or_guest_user)
      flash[:notice] = "Вы успешно покинули игру"
      render :leave, formats: %i[turbo_stream] # removes turbo_stream that streams the game and then issues a redirect!
    else
      flash[:alert] = "Не удалось покинуть игру"
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
      flash.now[:notice] = "Игрок кикнут"
    else
      response.status = :unprocessable_entity
      flash.now[:alert] = "Игрок не был кикнут"
    end

    render_turbo_flash
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
    params.require(:game).permit(:name, :viewable, :viewers_vote, :max_players, :max_rounds, :max_round_time, :max_points)
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
