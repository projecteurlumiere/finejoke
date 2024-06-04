class GameChannel < ApplicationCable::Channel
  def subscribed
    set_user
    set_game

    stream_for @game
    @game.touch unless @user.host?
  end

  def unsubscribed
    @game.reload
    @user.reload

    if current_user.host?
      @game.destroy
    else
      @game.users.delete(@user)
      @game.touch
    end

    @user.reset_game_attributes
  end

  private

  def set_user
    @user = current_user
  end

  def set_game
    @game = Game.find_by(id: params[:id])
    # if rejection happens turbo_stream tag in html doesn't get connected attribute
    reject if @game.nil?
    reject unless @game.joinable?(by: @user)

    @game.add_user(@user)
  end
end
