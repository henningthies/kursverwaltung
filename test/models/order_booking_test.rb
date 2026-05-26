require "test_helper"

class OrderBookingTest < ActiveSupport::TestCase
  setup do
    @user = users(:learner)
  end

  def paid_order_for(*course_list)
    order = @user.orders.build(status: "pending")
    order.add_courses(course_list)
    order.save!
    order.mark_paid!
    order
  end

  test "marking paid books the user into the ordered courses via Course#enroll" do
    order = nil
    assert_difference "Enrollment.count", 1 do
      order = paid_order_for(courses(:prompt_engineering))
    end
    participant = @user.participants.first
    assert_not_nil participant
    enrollment = courses(:prompt_engineering).enrollments.find_by(participant: participant)
    assert_equal "confirmed", enrollment.status
  end

  test "derives a participant from the user (find_or_create_by email)" do
    paid_order_for(courses(:prompt_engineering))
    participant = Participant.find_by(email: @user.email)
    assert_not_nil participant
    assert_equal @user, participant.user
  end

  test "a paid booking on a full course goes to the waitlist (no refund)" do
    full = courses(:notion_mastery)   # capacity 1, bob confirmed via fixture → full
    assert full.full?
    order = paid_order_for(full)
    participant = @user.participants.first
    enrollment = full.enrollments.find_by(participant: participant)
    assert_equal "waitlisted", enrollment.status
    # Order bleibt paid — keine automatische Rückerstattung.
    assert order.paid?
  end

  test "booking is idempotent: a second mark_paid! does not double-enroll" do
    order = paid_order_for(courses(:prompt_engineering))
    assert_no_difference "Enrollment.count" do
      order.send(:book_enrollments!)   # zweiter Webhook-Aufruf simuliert
    end
  end

  test "reuses an existing participant linked to the user" do
    existing = Participant.create!(name: @user.name, email: @user.email, user: @user)
    paid_order_for(courses(:prompt_engineering))
    assert_equal 1, @user.participants.count
    assert_equal existing, @user.participants.first
  end

  test "does not book while the order is still pending" do
    order = @user.orders.build(status: "pending")
    order.add_courses([courses(:prompt_engineering)])
    assert_no_difference "Enrollment.count" do
      order.save!
    end
  end
end
