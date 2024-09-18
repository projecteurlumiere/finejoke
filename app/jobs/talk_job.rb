class TalkJob < ApplicationJob
  queue_as :urgent

  def perform(host_id, target_situation)
    host = VirtualHost.includes(game: [:current_round, :users]).find_by(id: host_id)
    host.talk if host&.situation == target_situation
  end
end
