class GamesController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_game, only: %i[ show update destroy ]
  before_action :authorize_game!, only: %i[ index show update destroy ]

  # GET /games or /games.json
  def index
    @game = current_or_guest_user.game

    @games = Game.includes(:users).all
    clean_up_games
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
        format.html { redirect_to game_url(@game), notice: "Game was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # submits chat message
  def update
    @game.broadcast_chat_message(from: current_or_guest_user, message: chat_params[:message])
    head :accepted
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
    authorize_game!

    if @game.add_user(current_or_guest_user)
      redirect_to game_path(@game), notice: "You have joined the game"
    else
      redirect_to games_path, alert: "Something went wrong"
    end
  end

  def leave # game
    @game = Game.includes(:users).find(params[:game_id])
    authorize_game!

    if @game.remove_user(current_or_guest_user)
      disconnect_cable if params[:cable] == "disconnect"
      current_or_guest_user.update(connected: false)
      redirect_to games_path, notice: "You have left the game"
    else
      redirect_to games_path, alert: "Something went wrong"
    end
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
    params.require(:game).permit(:name, :max_players, :max_rounds, :max_round_time, :max_points)
  end

  def chat_params
    params.require(:game).permit(:message)
  end

  def create_game
    ActiveRecord::Base.transaction do
      current_or_guest_user.host = true
      @game.users << current_or_guest_user && current_or_guest_user.save
    end
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
      if game.users.any? { |user| user.host? }
        true
      else
        game.destroy
        false
      end 
    end
  end

  def disconnect_cable
    ActionCable.server.remote_connections.where(current_or_guest_user: current_or_guest_user).disconnect
  end
end
