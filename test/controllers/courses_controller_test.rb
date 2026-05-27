require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:claude_code)
    sign_in_as(users(:admin))
  end

  test "index lists the courses" do
    get courses_url
    assert_response :success
    assert_select "h1", "Kurse"
    assert_select "h2", text: "Claude Code im Projektalltag"
  end

  test "index shows the session count per course" do
    get courses_url
    assert_response :success
    assert_select "p", text: /2 Termine/
  end

  test "index shows the confirmed enrollment count per course" do
    get courses_url
    assert_response :success
    # claude_code hat eine bestätigte Anmeldung (alice) via Fixture.
    assert_select "p", text: /1 Anmeldung/
  end

  test "participants export returns name and email as json (deliberate PII demo)" do
    get participants_course_url(@course, format: :json)
    assert_response :success
    people = JSON.parse(response.body)
    # claude_code hat genau einen Teilnehmer (alice) via Fixture.
    assert_equal 1, people.size
    assert_equal "Alice Müller", people.first["name"]
    assert_equal "alice@example.com", people.first["email"]
  end

  test "show displays a course with its sessions" do
    get course_url(@course)
    assert_response :success
    assert_select "h1", "Claude Code im Projektalltag"
    assert_select "h2", "Termine"
  end

  test "creates a course with valid params" do
    assert_difference "Course.count", 1 do
      post courses_url, params: { course: { title: "Neuer Kurs", status: "draft" } }
    end
    assert_redirected_to course_url(Course.last)
    assert_equal "Neuer Kurs", Course.last.title
  end

  test "rejects a course with a blank title" do
    assert_no_difference "Course.count" do
      post courses_url, params: { course: { title: "", status: "draft" } }
    end
    assert_response :unprocessable_entity
  end

  test "updates a course" do
    patch course_url(@course), params: { course: { title: "Geändert" } }
    assert_redirected_to course_url(@course)
    assert_equal "Geändert", @course.reload.title
  end

  test "destroys a course" do
    assert_difference "Course.count", -1 do
      delete course_url(@course)
    end
    assert_redirected_to courses_url
  end
end
