class RoundsController < ApplicationController
  before_action :verify_turbo_stream_format
  before_action :set_game, only: %i[ show show_current create update skip_results ]
  before_action :set_round, only: %i[ show update skip_results ]
  before_action :authorize_round!, only: %i[show show_current update skip_results]
  after_action :try_to_force_new_round, only: %i[skip_results]

  # GET /rounds/1
  # shows round (for current round mainly)s
  def show
    render layout: false, formats: %i[turbo_stream], locals: { game: @game, round: @round }
  end

  def show_current
    @round = @game.current_round
    render :show, layout: false, formats: %i[turbo_stream], locals: { game: @game, round: @round }
  end

  # POST /rounds
  # creates round
  def create
    @round = @game.rounds.build
    authorize_round!
    
    if @round.save
      response.status = :accepted
      flash.now[:notice] = t(:".round_created")
    else
      response.status = :unprocessable_entity
      flash.now[:alert] = t(:".round_not_created")
    end

    render_turbo_flash
  end

  # PATCH/PUT /rounds/1
  # updates round with setup
  def update
    if @round.lock!.update(round_params)
      response.status = :accepted
      flash.now[:notice] = t(:".setup_created")
    else
      response.status = :unprocessable_entity
      flash.now[:alert] = t(:".setup_not_created")
    end

    render_turbo_flash
  end

  def skip_results
    response.status = :accepted
    flash.now[:notice] = t(:".you_voted_to_skip_results")
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
    authorize @round || Round
  end

  def pundit_user
    {
      user: current_or_guest_user,
      game: @game
    }
  end

  def try_to_force_new_round
    Game.transaction do
      current_or_guest_user.update_attribute(:wants_to_skip_results, true)

      if @game.users.where(hot_join: false).pluck(:wants_to_skip_results).all?(true)
        CreateNewRoundJob.perform_now(@game.id, @round.id)
      end
    end
  end
end
