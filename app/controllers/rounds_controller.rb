class RoundsController < ApplicationController
  before_action :set_game, only: %i[ show edit create update destroy ]
  before_action :set_round, only: %i[ show edit update destroy ]

  # GET /rounds or /rounds.json
  def index
    @rounds = Round.where(game_id: params[:game_id]).all
  end

  # GET /rounds/1 or /rounds/1.json
  def show
  end

  # GET /rounds/new
  def new
    @round = Round.new
  end

  # GET /rounds/1/edit
  def edit
  end

  # POST /rounds or /rounds.json
  def create
    @round = @game.rounds.build(user_id: @game.choose_lead.id)

    respond_to do |format|
      if @round.save
        @game.update_attribute(:started, true)
        format.html { redirect_to game_round_url(@game, @round), notice: "Round was successfully created." }
        format.json { render :show, status: :created, location: @round }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @round.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rounds/1 or /rounds/1.json
  def update
    respond_to do |format|
      if @round.update(round_params)
        @round.punchline_stage!

        format.html { redirect_to game_round_url(@game, @round), notice: "Round was successfully updated." }
        format.json { render :show, status: :ok, location: @round }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @round.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rounds/1 or /rounds/1.json
  def destroy
    @round.destroy!

    respond_to do |format|
      format.html { redirect_to rounds_url, notice: "Round was successfully destroyed." }
      format.json { head :no_content }
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
