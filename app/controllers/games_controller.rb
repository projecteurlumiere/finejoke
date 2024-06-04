class GamesController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_game, only: %i[ show destroy ]

  # GET /games or /games.json
  def index
    @games = Game.all
  end

  # joins game
  def show
    redirect_to games_path, flash: { alert: "Game is not joinable" } unless @game.joinable?(by: current_user)
  end

  # new game form
  def new
    @game = Game.new
  end

  # creates game
  def create
    @game = Game.new(game_params)

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
end
