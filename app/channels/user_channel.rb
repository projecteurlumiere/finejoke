class UserChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_or_guest_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
