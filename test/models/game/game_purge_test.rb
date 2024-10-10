require "test_helper"

class GamePurgeTest < ActiveSupport::TestCase  
  def setup
    @pubilc_game = games(:one)
    @private_game = games(:two)
    @private_game.update_attribute(:private, true)

    @private_game.users.each do |u|
      @private_game.remove_user(u)
    end
  end

  def test_private_game_purge
    assert -> { 
      @private_game.blank? && @public_game.present?
    }
  end

  def test_private_jokes_purge
    assert -> { 
      jokes(:one).present? && jokes(:two).present?
      jokes(:three).blank? && jokes(:four).blank?
    }
  end

  def test_private_rounds_purge
    assert -> {
      rounds(:one).present? &&
      rounds(:two).blank?
    }
  end

  def test_private_setups_purge
    assert -> {
      setups(:one).present? &&
      setups(:two).blank?
    }
  end

  def test_private_virtual_host_purge
    assert -> {
      virtual_hosts(:one).present? &&
      virtual_hosts(:two).blank?
    }
  end

  def test_private_prompts_purge
    assert -> {
      prompts(:one).present? &&
      prompts(:two).blank?
    }
  end

  def test_users_removed_from_private_game
    assert -> {
      %i[one two three].each do |n|
        return false if users(n).game_id != @public_game.id
      end &&
      %i[four five six].each do |n|
        return false if users(n).game_id != nil
      end
    }
  end

  def test_private_suggestions_purge
    assert -> {
      suggestions(:one).present? &&
      suggestions(:two).present? &&
      suggestions(:three).blank? &&
      suggestions(:four).blank?
    }
  end
end
  