require "test_helper"

class MyCoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @learner = users(:learner)
    # Lena als Teilnehmerin mit einer bestätigten und einer Wartelisten-Anmeldung.
    @participant = Participant.create!(name: @learner.name, email: @learner.email, user: @learner)
    courses(:claude_code).enrollments.create!(participant: @participant, status: "confirmed")
    courses(:notion_mastery).enrollments.create!(participant: @participant, status: "waitlisted")
  end

  test "my courses requires login" do
    get my_courses_url
    assert_redirected_to new_session_url
  end

  test "lists the logged-in learner's confirmed courses" do
    sign_in_as(@learner)
    get my_courses_url
    assert_response :success
    assert_select "h3", text: "Claude Code im Projektalltag"
  end

  test "shows waitlisted courses with a hint" do
    sign_in_as(@learner)
    get my_courses_url
    assert_match "Notion Mastery", response.body
    assert_match(/Warteliste/, response.body)
  end

  test "does not show another user's courses" do
    other = users(:admin)
    other_participant = Participant.create!(name: "Andi", email: other.email, user: other)
    courses(:prompt_engineering).enrollments.create!(participant: other_participant, status: "confirmed")

    sign_in_as(@learner)
    get my_courses_url
    assert_select "h3", text: "Prompt Engineering meistern", count: 0
  end

  test "completing a paid checkout books the course into my courses" do
    sign_in_as(@learner)
    post add_item_cart_url(course_id: courses(:free_intro).id)
    post checkout_url   # free → sofort paid + gebucht
    get my_courses_url
    assert_match "Einführung in KI", response.body
  end
end
