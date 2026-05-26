require "test_helper"

class CatalogShowTest < ActionDispatch::IntegrationTest
  test "show is reachable without login for an active course" do
    course = courses(:prompt_engineering)
    get catalog_course_url(course)
    assert_response :success
    assert_select "h1", text: course.title
  end

  test "show displays price, category and instructor" do
    course = courses(:claude_code)
    get catalog_course_url(course)
    assert_match(/129,00/, response.body)
    assert_match course.category.name, response.body
    assert_match course.instructor, response.body
  end

  test "show lists the course sessions as syllabus" do
    course = courses(:claude_code)
    course.sessions.create!(title: "Auftakt", starts_at: "2026-06-01 18:00")
    get catalog_course_url(course)
    course.sessions.each do |session|
      assert_match session.title, response.body
    end
  end

  test "free course shows Gratis and a direct booking action" do
    course = courses(:free_intro)   # price 0, active
    get catalog_course_url(course)
    assert_match "Gratis", response.body
    assert_match "Jetzt buchen", response.body
  end

  test "full course shows a waitlist hint" do
    course = courses(:notion_mastery)   # capacity 1, bob confirmed → full
    assert course.full?
    get catalog_course_url(course)
    assert_match(/Warteliste/, response.body)
  end

  test "draft course is not publicly viewable" do
    course = courses(:rails_performance)   # draft
    get catalog_course_url(course)
    assert_response :not_found
  end

  test "done course is not publicly viewable" do
    course = courses(:git_for_teams)   # done
    get catalog_course_url(course)
    assert_response :not_found
  end
end
