module Games
  module VirtualHost
    extend ActiveSupport::Concern
    
    included do 
      has_one :virtual_host

      after_save :virtual_host_takes_mic

      def virtual_host_takes_mic
        virtual_host&.talk_later if finished? || on_halt?
      end
    end
  end
end

