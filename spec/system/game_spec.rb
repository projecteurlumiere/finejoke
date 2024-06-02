require "rails_helper"

RSpec.describe "Game" do 
  it "connects to lobby" do
    visit root_path
    expect(page).to have_content("Games")
  end
end