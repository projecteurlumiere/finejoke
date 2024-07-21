class JokesController < ApplicationController
  before_action :set_game, only: %i[ show create update]
  before_action :set_round, only: %i[ show create update ]
  before_action :set_joke, only: %i[ show update ]
  before_action :authorize_joke!, only: %i[ show update ]

  def index
    raise "not implemented"
  end

  def show
    raise "not implemented"
  end

  # creates a joke with punchline
  def create
    @joke = @round.jokes.build(punchline_author_id: current_or_guest_user.id, setup_author_id: @round.user.id, setup: @round.setup, **joke_params)
    authorize_joke!
    
    if @joke.save
      response.status = :accepted
      flash.now[:notice] = "Шутка создана"
    else
      response.status = :unprocessable_entity
      flash.now[:alert] = "Шутка не создана"
    end

    render_turbo_flash
  end

  # registers a vote
  def update
    if @joke.register_vote(by: current_or_guest_user)
      response.status = :accepted
      flash.now[:notice] = "Голос учтён"
    else
      response.status = :unprocessable_entity
      flash.now[:alert] = "Голос не был учтён"
    end

    render_turbo_flash
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_round
    @round = @game.rounds.find(params[:round_id])
  end

  def set_joke
    @joke = Joke.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def joke_params
    params.require(:joke).permit(:punchline)
  end

  def authorize_joke!
    authorize(@joke || Joke)
  end
end
