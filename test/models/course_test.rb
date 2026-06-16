require "test_helper"

class CourseTest < ActiveSupport::TestCase
  setup do
    @course = courses(:claude_code)
  end

  # --- Epic 2: Preis + Kategorie ---

  test "price_cents must be a non-negative integer" do
    @course.price_cents = -1
    assert_not @course.valid?
  end

  test "free? is true only when price_cents is zero" do
    assert courses(:git_for_teams).free?
    assert_not courses(:claude_code).free?
  end

  test "published scope returns only active courses" do
    titles = Course.published.pluck(:title)
    assert_includes titles, "Claude Code im Projektalltag"   # active
    assert_includes titles, "Prompt Engineering meistern"    # active
    assert_not_includes titles, "Rails Performance"          # draft
    assert_not_includes titles, "Git für Teams"              # done
  end

  test "in_category filters by category, nil means all" do
    ki = categories(:ki)
    assert_equal [ "Einführung in KI", "Prompt Engineering meistern" ],
                 Course.in_category(ki).pluck(:title).sort
    assert_equal Course.count, Course.in_category(nil).count
  end

  test "remaining_seats is nil without capacity and clamps at zero" do
    assert_nil courses(:claude_code).remaining_seats
    full = courses(:git_for_teams)   # capacity 1, carol confirmed via fixture
    assert_equal 0, full.remaining_seats
  end

  test "almost_full? flags scarce capacity but not unlimited or full courses" do
    assert_not courses(:claude_code).almost_full?   # unbegrenzt
    assert_not courses(:git_for_teams).almost_full? # voll → eigener Zustand
  end

  test "belongs_to category is optional" do
    @course.category = nil
    assert @course.valid?
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

  # Wiederanmeldung nach Stornierung reaktiviert die bestehende Anmeldung (kein Duplikat)
  test "re-enroll after cancel reactivates the existing enrollment" do
    course = courses(:rails_performance)
    alice = participants(:alice)
    first = course.enroll(alice)
    first.cancel
    second = course.enroll(alice)
    assert_equal first.id, second.id
    assert_equal "confirmed", second.status
    assert_equal 1, course.confirmed_count
  end

  # --- Reviews ---

  test "has_many reviews with dependent destroy" do
    course = courses(:claude_code)
    assert_equal 2, course.reviews.count
    assert_difference "Review.count", -2 do
      course.destroy
    end
  end

  test "average_rating calculates average of visible reviews" do
    course = courses(:claude_code)
    # learner_public (5) + learner2_anonymous (4) = (5+4)/2 = 4.5
    assert_equal 4.5, course.average_rating
  end

  test "average_rating excludes invisible reviews" do
    course = courses(:prompt_engineering)
    # learner_private (3, visible: false) — should not count
    assert_nil course.average_rating # no visible reviews
  end

  test "average_rating returns nil when no visible reviews" do
    course = courses(:rails_performance)
    assert_nil course.average_rating
  end

  test "reviews_count counts only visible reviews" do
    course = courses(:claude_code)
    # learner_public + learner2_anonymous = 2 visible
    assert_equal 2, course.reviews_count
  end

  test "reviews_count excludes invisible reviews" do
    course = courses(:prompt_engineering)
    # learner_private is invisible
    assert_equal 0, course.reviews_count
  end

  test "reviewed_by? returns true if user has reviewed the course" do
    course = courses(:claude_code)
    assert course.reviewed_by?(users(:learner))
    assert course.reviewed_by?(users(:learner2))
    assert_not course.reviewed_by?(users(:admin))
  end

  test "reviewed_by? returns false for nil user" do
    course = courses(:claude_code)
    assert_not course.reviewed_by?(nil)
  end
end
