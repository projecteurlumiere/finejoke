class GameChannel < ApplicationCable::Channel
  include Monitorable

  # it is not possible to disconnect user from chanenl or stream from controller or model
  # therefore the channel periodically checks whether user is in game
  # to ensure he was not kicked and still has the right to receive game and game chat updates
  # this is not necessary anymore because all games are always viewable
  # periodically every: 1.minute do
  #   stop_stream_for @game unless user_in_game?
  # end

  def subscribed
    set_user
    set_game

    stream_for @game
    @game.increment!(:n_viewers)
  end

  def unsubscribed
    @game&.decrement!(:n_viewers)
  end

  private

  def set_user
    @user = current_or_guest_user
  end

  def set_game
    @game = Game.find_by(id: params[:id])

    # if rejection happens turbo_stream tag in html doesn't get connected attribute
    reject if @game.nil?
    return if @game.viewable?
    reject if @game.users.none?(@user)
  end

  # this is not used anymore. see the top of the file 
  def user_in_game?
    User.where(id: @user.id).pluck(:game_id)[0] == @game.id
  end
end
