module Games
  module VirtualHost
    extend ActiveSupport::Concern
    
    included do 
      has_one :virtual_host, dependent: :nullify

      attribute :create_with_virtual_host, :boolean, default: false

      after_create :invite_host, if: :create_with_virtual_host

      after_save :virtual_host_takes_mic

      def invite_host
        return if ::VirtualHost.disabled? ||
                  ::VirtualHost.where(locale: locale)
                               .where.not(game_id: nil)
                               .count >= 1
        
        self.virtual_host = ::VirtualHost.new(locale:)
        save!
      end

      def virtual_host_takes_mic
        virtual_host&.talk_later if status_previously_changed? && (finished? || on_halt?)
      end
    end
  end
end

