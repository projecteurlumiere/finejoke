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
    @joke = @round.jokes.build(user_id: current_user.id)
    authorize_joke!
    
    respond_to do |format|
      if @joke.save
        format.html { redirect_to game_round_url(@game, @round), notice: "Joke was successfully created." }
      else
        flash.now[:alert] = "Joke was not created."
        format.turbo_stream {
          render partial: "shared/flash", status: :unprocessable_entity
        }
      end
    end
  end

  # registers a vote
  def update
    respond_to do |format|
      if @joke.register_vote(by: current_user)
        format.html { redirect_to game_round_url(@game, @round), notice: "Joke was successfully updated." }
      else
        flash.now[:alert] = "Joke was not updated."
        format.turbo_stream { 
          render partial: "shared/flash", status: :unprocessable_entity 
        }
      end
    end
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
