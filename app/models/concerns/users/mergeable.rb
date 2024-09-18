module Users
  module Mergeable
    extend ActiveSupport::Concern

    included do 
      def merge(user)
        user.game&.remove_user(user)
        self.total_score += user.total_score
        merge_jokes(user)
        merge_awards(user)

        save(validate: false)
      end

      private

      def merge_jokes(user)
        user.finished_jokes.update_all(punchline_author_id: id)
        user.started_jokes.update_all(setup_author_id: id)
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
