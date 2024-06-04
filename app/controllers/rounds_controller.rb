class RoundsController < ApplicationController
  before_action :set_game, only: %i[ show create update ]
  before_action :set_round, only: %i[ show update ]

  # GET /rounds/1
  # shows round (for current round mainly)
  def show
  end

  # POST /rounds
  # creates round
  def create
    @round = @game.rounds.build

    respond_to do |format|
      if @round.save
        format.html { redirect_to game_round_url(@game, @round), notice: "Round was successfully created." }
      else
        flash.now[:alert] = "Round was not created."
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace("flash", partial: "layouts/flash"), status: :unprocessable_entity
        }
      end
    end
  end

  # PATCH/PUT /rounds/1
  # updates round with setup
  def update
    respond_to do |format|
      if @round.update(round_params)
        format.html { redirect_to game_round_url(@game, @round), notice: "Round was successfully updated." }
      else
        format.html { redirect_to game_round_url(@game, @round), alert: "Round was not updated." }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:game_id])
    end

    def set_round
      @round = @game.rounds.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def round_params
      params.require(:round).permit(:setup)
    end
end
