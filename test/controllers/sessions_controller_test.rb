require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:claude_code)
    sign_in_as(users(:admin))
  end

  test "adds a session to a course" do
    assert_difference "@course.sessions.count", 1 do
      post course_sessions_url(@course), params: {
        session: { title: "Neuer Termin", starts_at: "2026-08-01 18:00" }
      }
    end
    assert_redirected_to course_url(@course)
  end

  test "rejects a session with a blank title" do
    assert_no_difference "Session.count" do
      post course_sessions_url(@course), params: { session: { title: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "removes a session from a course" do
    session = sessions(:claude_termin_1)
    assert_difference "@course.sessions.count", -1 do
      delete course_session_url(@course, session)
    end
    assert_redirected_to course_url(@course)
  end
end
