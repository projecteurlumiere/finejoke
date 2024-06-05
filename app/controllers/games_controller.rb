class GamesController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_game, only: %i[ show destroy ]
  before_action :authorize_game!, only: %i[index show destroy]

  # GET /games or /games.json
  def index
    current_user.reset_game_attributes
    @games = Game.includes(:users).all
    clean_up_games
  end

  # joins game
  def show
    redirect_to games_path, flash: { alert: "Game is not joinable" } unless @game.joinable?(by: current_user)
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

  # DELETE /games/1 or /games/1.json
  def destroy
    @game.destroy!

    respond_to do |format|
      format.html { redirect_to games_url, notice: "Game was successfully destroyed." }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.includes(:users).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def game_params
    params.require(:game).permit(:name, :max_players, :max_rounds, :max_round_time, :max_points)
  end

  def create_game
    ActiveRecord::Base.transaction do
      current_user.host = true
      @game.users << current_user && current_user.save
    end
  end

  def authorize_game!
    authorize @game || Game
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
end
