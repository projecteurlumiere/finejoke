module Rounds
  module VirtualHost
    extend ActiveSupport::Concern

    included do
      before_save :toggle_call_virtual_host
      after_commit :virtual_host_takes_mic

      def toggle_call_virtual_host
        @call_virtual_host = stage_changed? || new_record?
      end

      def virtual_host_takes_mic
        game.virtual_host&.talk_later(self) if @call_virtual_host
      end
    end
  end
end