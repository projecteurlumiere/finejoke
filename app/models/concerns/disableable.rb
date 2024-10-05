module Disableable
  extend ActiveSupport::Concern

  included do
    def self.disabled?
      raise "expect DISABLEABLE_KEY definition in the extendeable class #{self.class}" unless self.const_defined?(:DISABLEABLE_KEY)

      ENV.fetch(self.const_get(:DISABLEABLE_KEY), "").present?
    end

    def self.enabled?
      !self.disabled?
    end
  end
end
