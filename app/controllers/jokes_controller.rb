class JokesController < ApplicationController
  before_action :set_game, only: %i[ show create vote]
  before_action :set_round, only: %i[ show create vote ]
  before_action :set_joke, only: %i[ show vote ]
  before_action :authorize_joke!, only: %i[ show vote ]

  def index
    raise "not implemented"
  end

  def show
    raise "not implemented"
  end

  # creates a joke with punchline
  def create
    @joke = @round.jokes.build(
      user_id: current_or_guest_user.id, 
      setup_model_id: @round.setup_model.id, 
      **joke_params
    )
    authorize_joke!
    
    if @joke.save
      response.status = :ok
      flash.now[:notice] = t(:".joke_created")
      reload_game_state
      render "rounds/show", layout: false, formats: %i[turbo_stream], locals: { game: @game, round: @round }
    else
      response.status = :unprocessable_entity
      flash.now[:alert] = t(:".joke_not_created")
      render_turbo_flash
    end

  end

  # registers a vote
  def vote
    if @joke.register_vote(by: current_or_guest_user)
      response.status = :ok
      flash.now[:notice] = t(:".vote_counted")
    else
      response.status = :unprocessable_entity
      flash.now[:alert] = t(:".vote_not_counted")
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

  def reload_game_state
    [@game, @round, current_or_guest_user].each do |model|
      model.reload
    end
  end
end
