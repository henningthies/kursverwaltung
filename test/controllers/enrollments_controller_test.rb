require "test_helper"

class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:rails_performance)  # capacity: 2, starts with 0 enrollments
  end

  test "create enrolls a new participant as confirmed" do
    assert_difference "Enrollment.count", 1 do
      post course_enrollments_url(@course), params: {
        enrollment: { name: "Fritz Mayer", email: "fritz@example.com" }
      }
    end
    enrollment = Enrollment.last
    assert_equal "confirmed", enrollment.status
    assert_equal "Fritz Mayer", enrollment.participant.name
    assert_redirected_to course_url(@course)
    assert_match "Anmeldung bestätigt", flash[:notice]
  end

  test "create enrolls into a full course as waitlisted" do
    # fill the course first
    post course_enrollments_url(@course), params: {
      enrollment: { name: "Slot 1", email: "slot1@example.com" }
    }
    post course_enrollments_url(@course), params: {
      enrollment: { name: "Slot 2", email: "slot2@example.com" }
    }
    # course is now full (capacity: 2)
    assert_difference "Enrollment.count", 1 do
      post course_enrollments_url(@course), params: {
        enrollment: { name: "Warteliste", email: "warteliste@example.com" }
      }
    end
    assert_equal "waitlisted", Enrollment.last.status
    assert_redirected_to course_url(@course)
    assert_match "Warteliste", flash[:notice]
  end

  test "create with blank name returns unprocessable_entity" do
    assert_no_difference "Enrollment.count" do
      post course_enrollments_url(@course), params: {
        enrollment: { name: "", email: "noname@example.com" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create with blank email returns unprocessable_entity" do
    assert_no_difference "Enrollment.count" do
      post course_enrollments_url(@course), params: {
        enrollment: { name: "Kein Email", email: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "destroy cancels enrollment and promotes waitlisted" do
    # enroll alice (confirmed), bob (confirmed = full), carol (waitlisted)
    alice_enrollment = @course.enroll(participants(:alice))
    @course.enroll(participants(:bob))
    carol_enrollment = @course.enroll(participants(:carol))

    assert_difference "Enrollment.count", 0 do
      delete course_enrollment_url(@course, alice_enrollment)
    end
    assert_equal "cancelled", alice_enrollment.reload.status
    assert_equal "confirmed", carol_enrollment.reload.status
    assert_redirected_to course_url(@course)
    assert_match "Abmeldung", flash[:notice]
  end

  test "destroy with no waitlist just cancels, no error" do
    enrollment = @course.enroll(participants(:alice))
    assert_nothing_raised do
      delete course_enrollment_url(@course, enrollment)
    end
    assert_equal "cancelled", enrollment.reload.status
    assert_redirected_to course_url(@course)
  end
end
