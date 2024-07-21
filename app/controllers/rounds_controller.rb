class RoundsController < ApplicationController
  before_action :set_game, only: %i[ show create update ]
  before_action :set_round, only: %i[ show update ]
  before_action :authorize_round!, only: %i[show update]

  # GET /rounds/1
  # shows round (for current round mainly)
  def show
    render layout: false, formats: %i[turbo_stream], locals: { game: @game, round: @round }
  end

  # POST /rounds
  # creates round
  def create
    @round = @game.rounds.build
    authorize_round!
    
    if @round.save
      response.status = :accepted
      flash.now[:notice] = "Раунд создан"
    else
      response.status = :unprocessable_entity
      flash.now[:alert] = "Раунд не создан"
    end

    render_turbo_flash
  end

  # PATCH/PUT /rounds/1
  # updates round with setup
  def update
    if @round.update(round_params)
      response.status = :accepted
      flash.now[:notice] = "Завязка создана"
    else
      response.status = :unprocessable_entity
      flash.now[:alert] = "Завязка не создана"
    end

    render_turbo_flash
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

  def authorize_round!
    authorize(@round || Round)
  end
end
