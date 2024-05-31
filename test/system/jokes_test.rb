require "application_system_test_case"

class JokesTest < ApplicationSystemTestCase
  setup do
    @joke = jokes(:one)
  end

  test "visiting the index" do
    visit jokes_url
    assert_selector "h1", text: "Jokes"
  end

  test "should create joke" do
    visit jokes_url
    click_on "New joke"

    fill_in "Punchline", with: @joke.punchline
    fill_in "Round", with: @joke.round_id
    fill_in "Text", with: @joke.text
    click_on "Create Joke"

    assert_text "Joke was successfully created"
    click_on "Back"
  end

  test "should update Joke" do
    visit joke_url(@joke)
    click_on "Edit this joke", match: :first

    fill_in "Punchline", with: @joke.punchline
    fill_in "Round", with: @joke.round_id
    fill_in "Text", with: @joke.text
    click_on "Update Joke"

    assert_text "Joke was successfully updated"
    click_on "Back"
  end

  test "should destroy Joke" do
    visit joke_url(@joke)
    click_on "Destroy this joke", match: :first

    assert_text "Joke was successfully destroyed"
  end
end
