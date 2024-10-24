class MessagesController < ApplicationController
  before_action :verify_turbo_stream_format
  before_action :set_game, only: %i[ create ]

  # creates game
  def create
    @message = Message.new(user: current_or_guest_user, game: @game, **message_params)
    authorize_message!

    if @message.valid? && @message.broadcast
      response.status = :accepted   
      flash.now[:notice] = t(:".message_sent") unless Rails.env.production?
    else
      response.status = :unprocessable_entity
      flash.now[:alert] = t(:".message_not_sent")
    end
    
    render_turbo_flash
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.includes(:virtual_host).find(params[:game_id])
  end

  # Only allow a list of trusted parameters through.
  def message_params
    params.require(:message).permit(:text)
  end

  def authorize_message!
    authorize @message || Message
  end
end
