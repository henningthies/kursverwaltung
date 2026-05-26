require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  test "STATUSES contains confirmed, waitlisted, cancelled" do
    assert_equal %w[confirmed waitlisted cancelled], Enrollment::STATUSES
  end

  test "rejects a status outside STATUSES" do
    enrollment = Enrollment.new(
      course: courses(:claude_code),
      participant: participants(:alice),
      status: "unknown"
    )
    assert_not enrollment.valid?
    assert_includes enrollment.errors[:status], "ist kein gültiger Wert"
  end

  test "scope confirmed returns only confirmed enrollments" do
    confirmed = Enrollment.confirmed
    assert_equal 2, confirmed.count # alice (claude_code) + carol (git_for_teams)
    assert confirmed.all? { |e| e.status == "confirmed" }
  end

  test "scope waitlisted returns only waitlisted enrollments" do
    waitlisted = Enrollment.waitlisted
    assert_equal 1, waitlisted.count # dave (git_for_teams)
    assert_equal participants(:dave), waitlisted.first.participant
  end

  test "dependent destroy: removing course removes enrollments" do
    course = courses(:claude_code)
    count = course.enrollments.count
    assert_difference "Enrollment.count", -count do
      course.destroy
    end
  end

  test "dependent destroy: removing participant removes enrollments" do
    participant = participants(:alice)
    # alice is enrolled in claude_code via fixture
    assert_difference "Enrollment.count", -1 do
      participant.destroy
    end
  end

  test "unique index: double-enroll same participant blocked" do
    course = courses(:claude_code)
    # alice is already enrolled in claude_code via fixture
    duplicate = Enrollment.new(
      course: course,
      participant: participants(:alice),
      status: "confirmed"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:participant_id], "ist bereits vergeben"
  end
end
