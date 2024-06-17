class GameChannel < ApplicationCable::Channel
  def subscribed
    set_user
    set_game

    stream_for @game
    @game.touch unless @user.host?
    @user.toggle!(:subscribed_to_game)
  end

  def unsubscribed
    @user.toggle!(:subscribed_to_game)
    
    RemoveUserFromGameJob.set(wait: 5.seconds).perform_later(@user.id, @game.id) if @rejected
  end

  private

  def set_user
    @user = current_or_guest_user
  end

  def set_game
    @game = Game.find_by(id: params[:id])
    # if rejection happens turbo_stream tag in html doesn't get connected attribute
    if @game.nil? || !@game.users.include?(@user)
      @rejected = true
      reject
    end

    @game.add_user(@user)
  end
end
