class CleanUpExpiredBansJob < ApplicationJob
  queue_as :default

  def perform
    Ban.clean_up_expired_bans
    Rails.cache.delete("clean_up_expired_bans_scheduled")
  end
end
