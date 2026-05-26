require "test_helper"

class CourseTest < ActiveSupport::TestCase
  setup do
    @course = courses(:claude_code)
  end

  test "requires a title" do
    @course.title = ""
    assert_not @course.valid?
    assert_includes @course.errors[:title], "muss ausgefüllt werden"
  end

  test "rejects a status outside STATUSES" do
    @course.status = "archived"
    assert_not @course.valid?
    assert_includes @course.errors[:status], "ist kein gültiger Wert"
  end

  test "accepts every status in STATUSES" do
    Course::STATUSES.each do |status|
      @course.status = status
      assert @course.valid?, "#{status} sollte gültig sein"
    end
  end

  test "ordered scope sorts courses by title" do
    titles = Course.ordered.pluck(:title)
    assert_equal titles.sort, titles
  end

  test "destroying a course destroys its sessions" do
    assert_equal 2, @course.sessions.count
    assert_difference "Session.count", -2 do
      @course.destroy
    end
  end

  test "capacity 0 is invalid" do
    @course.capacity = 0
    assert_not @course.valid?
  end

  # EC-01 — free capacity → confirmed
  test "enroll into course with free capacity creates confirmed enrollment" do
    course = courses(:rails_performance)   # capacity: 2, 0 confirmed
    participant = participants(:alice)
    enrollment = course.enroll(participant)
    assert_equal "confirmed", enrollment.status
    assert_equal 1, course.confirmed_count
  end

  # EC-02 — course exactly full → next enrollment is waitlisted
  test "enroll into full course creates waitlisted enrollment" do
    course = courses(:rails_performance)   # capacity: 2
    course.enroll(participants(:alice))
    course.enroll(participants(:bob))
    # course now full
    enrollment = course.enroll(participants(:carol))
    assert_equal "waitlisted", enrollment.status
    assert course.full?
  end

  # EC-03 — cancel confirmed spot → oldest waitlisted moves up, counter correct
  test "cancel confirmed spot promotes oldest waitlisted" do
    course = courses(:rails_performance)   # capacity: 2
    t0 = Time.current
    alice = travel_to(t0)           { course.enroll(participants(:alice)) }  # confirmed
    _bob  = travel_to(t0 + 1.second) { course.enroll(participants(:bob)) }   # confirmed (full)
    carol = travel_to(t0 + 2.seconds) { course.enroll(participants(:carol)) } # waitlisted
    _dave = travel_to(t0 + 3.seconds) { course.enroll(participants(:dave)) }  # waitlisted (later)
    alice.cancel
    assert_equal "cancelled",  alice.reload.status
    assert_equal "confirmed",  carol.reload.status   # oldest waiter
    assert_equal "waitlisted", _dave.reload.status
    assert_equal 2, course.confirmed_count
  end

  # EC-04 — cancel without waitlist → only cancelled, no error
  test "cancel confirmed enrollment with no waitlist does not raise" do
    course = courses(:rails_performance)
    enrollment = course.enroll(participants(:alice))
    assert_nothing_raised { enrollment.cancel }
    assert_equal "cancelled", enrollment.reload.status
    assert_equal 0, course.confirmed_count
  end

  # EC-05 — all cancelled → course empty, re-enroll works
  test "re-enroll after all cancellations works" do
    course = courses(:rails_performance)   # capacity: 2
    e1 = course.enroll(participants(:alice))
    e2 = course.enroll(participants(:bob))
    e1.cancel
    e2.cancel
    assert_equal 0, course.confirmed_count
    assert_not course.full?
    new_enrollment = course.enroll(participants(:carol))
    assert_equal "confirmed", new_enrollment.status
  end

  # EC-06 — capacity nil/0 (Boundary)
  test "full? returns false when capacity is nil" do
    course = courses(:claude_code)   # capacity: nil
    3.times { |i| course.enroll(Participant.create!(name: "X#{i}", email: "x#{i}@example.com")) }
    assert_not course.full?
  end

  # EC-07 — double-enroll same participant → blocked
  test "enrolling the same participant twice raises a record invalid error" do
    course = courses(:rails_performance)
    participant = participants(:alice)
    course.enroll(participant)
    assert_raises(ActiveRecord::RecordInvalid) do
      course.enroll(participant)
    end
  end
end
