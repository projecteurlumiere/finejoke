class ReplyJob < ApplicationJob
  queue_as :urgent

  def perform(host_id, username, msg)
    host = VirtualHost.includes(game: [:current_round, :users]).find_by(id: host_id)
    
    host&.reply(username, msg)
  end
end
