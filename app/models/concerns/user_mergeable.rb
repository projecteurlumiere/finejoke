module UserMergeable
  extend ActiveSupport::Concern

  included do 
    def merge(user)
      user.game&.remove_user(user)
      self.total_score += user.total_score
      merge_jokes(user)

      save(validate: false)
    end

    private

    def merge_jokes(user)
      user.finished_jokes.update_all(punchline_author_id: id)
      user.started_jokes.update_all(setup_author_id: id)
    end
  end
end
