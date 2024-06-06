class MessagesController < ApplicationController
  before_action :set_game, only: %i[ create ]

  # creates game
  def create
    @message = Message.new(user: current_or_guest_user, game: @game, **message_params)
    authorize_message!

    if @message.valid?
      @message.broadcast
      head :accepted
    else
      flash.now[:alert] = "Message was not created"
      respond_to do |format| 
        format.turbo_stream do
          render partial: "shared/flash", status: :unprocessable_entity
        end
      end
    end
    # @game.broadcast_chat_message(from: current_or_guest_user, message: chat_params[:message])
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.includes(:users).find(params[:game_id])
  end

  # Only allow a list of trusted parameters through.
  def message_params
    params.require(:message).permit(:text)
  end

  def authorize_message!
    authorize @message || Message
  end
end
