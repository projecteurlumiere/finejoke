module Sanitizable
  extend ActiveSupport::Concern

  # NOT IN USE!

  # add the following code to ApplicationRecord:

  # include Sanitizable

  # ATTRIBUTES_TO_SANITIZE = []
  # before_save -> { sanitize_attributes(ATTRIBUTES_TO_SANITIZE) }

  # and define ATTIRUBUTES_TO_SANITIZE for every model

  included do 
    def sanitize(str)
      ActionController::Base.helpers.sanitize(str)
    end

    # accepts array of symbols
    # updates attribute on instance
    def sanitize_attributes(attributes)
      attributes.each do |attribute|
        next unless new_record? || will_save_change_to_attribute?(attribute)

        attribute = "@#{attribute}"
        sanitized_str = sanitize(self.send(attribute))
        self.instance_variable_set(attribute, sanitized_str)
      end
    end
  end
end

