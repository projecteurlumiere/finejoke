class LobbyChannel < ApplicationCable::Channel
  def subscribed
    latest_locale = User.where(id: current_or_guest_user.id).pluck(:locale)[0]

    stream_from "lobby_#{latest_locale}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
