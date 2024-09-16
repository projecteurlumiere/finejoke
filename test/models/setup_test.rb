require "test_helper"

class SetupTest < ActiveSupport::TestCase
  def setup
    Setup.send(:remove_const, :TRUNCATE_LENGTH)
    Setup.const_set(:TRUNCATE_LENGTH, 20)
  end

  def truncate(string)
    Setup.truncate(string)
  end

  def test_truncate
    assert_equal(
      "I am a truncated test.",
      truncate("Hello! I am a truncated test.")
    )
  end

  def test_no_period_at_the_end
    assert_equal(
      "I am a truncated test",
      truncate("Hello! I am a truncated test")
    )
  end

  def test_other_punctuation
    assert_equal(
      "I am a truncated test!",
      truncate("Hello! I am a truncated test!")
    )
    assert_equal(
      "I am a truncated test?",
      truncate("Hello! I am a truncated test?")
    )

    assert_equal(
      "I am a truncated test...",
      truncate("Hello! I am a truncated test...")
    )

    assert_equal(
      "I am a truncated test:",
      truncate("Hello! I am a truncated test:")
    )

    assert_equal(
      'a truncated test...".',
      truncate('And it said: "I am a good person. I am a truncated test...".')
    )
  end

  def test_long_word
    string = "I am very looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong"

    assert_equal(
      string.slice(-Setup::TRUNCATE_LENGTH..-1),
      truncate(string)
      )

  end

  def test_long_sentence
    string = "I am a very long and wordy sentence.\ 
      Nothing is going to shorten me beyond this last sentence because I am so \
      cool and long string, yay, hooray, wohoo, hello, hi, I am a string by the way \
      did you know that?"

    assert -> {
      truncated_str = truncate(string) 
      truncated_str.length <= Setup::TRUNCATE_LENGTH..-1 &&
        string.end_with?(truncated_str)
    }
  end

  def test_not_needing_truncation
    assert_nil(truncate("Hello"))
  end
end
