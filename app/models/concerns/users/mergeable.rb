module Users
  module Mergeable
    extend ActiveSupport::Concern

    included do 
      def merge(user)
        transaction do 
          user.game&.remove_user(user)
          self.total_score += user.total_score
          merge_jokes(user)
          merge_awards(user)

          save(validate: false)
        end
      end

      private

      def merge_jokes(user)
        user.finished_jokes.update_all(user_id: id)
        
        setups = Setup.where(id: user.started_jokes.pluck(:id))
        setups&.update_all(user_id: id)
      end

      def merge_presents(user)
        user.awards.update_all(user_id: id)
      end

      def merge_awards(user)
        # to be done
      end
    end
  end
end
