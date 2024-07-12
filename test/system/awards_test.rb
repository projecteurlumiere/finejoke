require "application_system_test_case"

class AwardsTest < ApplicationSystemTestCase
  setup do
    @award = awards(:one)
  end

  test "visiting the index" do
    visit awards_url
    assert_selector "h1", text: "Awards"
  end

  test "should create award" do
    visit awards_url
    click_on "New award"

    fill_in "Present", with: @award.present_id
    fill_in "Signature", with: @award.signature
    fill_in "User", with: @award.user_id
    click_on "Create Award"

    assert_text "Award was successfully created"
    click_on "Back"
  end

  test "should update Award" do
    visit award_url(@award)
    click_on "Edit this award", match: :first

    fill_in "Present", with: @award.present_id
    fill_in "Signature", with: @award.signature
    fill_in "User", with: @award.user_id
    click_on "Update Award"

    assert_text "Award was successfully updated"
    click_on "Back"
  end

  test "should destroy Award" do
    visit award_url(@award)
    click_on "Destroy this award", match: :first

    assert_text "Award was successfully destroyed"
  end
end
