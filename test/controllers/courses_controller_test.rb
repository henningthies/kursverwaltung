require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:claude_code)
  end

  test "index lists the courses" do
    get courses_url
    assert_response :success
    assert_select "h1", "Kurse"
    assert_select "h2", text: "Claude Code im Projektalltag"
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
