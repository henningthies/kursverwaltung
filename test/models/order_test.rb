require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @user = users(:learner)
  end

  test "rejects a status outside STATUSES" do
    order = Order.new(user: @user, status: "refunded", total_cents: 0)
    assert_not order.valid?
    assert_includes order.errors[:status], "ist kein gültiger Wert"
  end

  test "add_courses builds order items with price snapshots and sums the total" do
    order = @user.orders.build(status: "pending")
    order.add_courses([ courses(:claude_code), courses(:prompt_engineering) ])
    assert_equal 2, order.order_items.size
    assert_equal [ 4900, 12900 ], order.order_items.map(&:price_cents).sort
    assert_equal 12900 + 4900, order.total_cents
  end

  test "price snapshot does not change when the course price later changes" do
    order = @user.orders.build(status: "pending")
    order.add_courses([ courses(:claude_code) ])
    order.save!
    courses(:claude_code).update!(price_cents: 1)
    assert_equal 12900, order.order_items.first.price_cents
  end

  test "mark_paid! sets status and paid_at" do
    order = @user.orders.create!(status: "pending", total_cents: 4900)
    freeze_time do
      order.mark_paid!
      assert order.paid?
      assert_equal Time.current, order.paid_at
    end
  end

  test "mark_paid! is idempotent (double webhook does not change paid_at)" do
    order = @user.orders.create!(status: "pending", total_cents: 4900)
    order.mark_paid!
    first_paid_at = order.paid_at
    travel 1.hour do
      order.mark_paid!
      assert_equal first_paid_at.to_i, order.reload.paid_at.to_i
    end
  end

  test "stripe_session_id is unique" do
    @user.orders.create!(status: "pending", total_cents: 0, stripe_session_id: "cs_test_1")
    duplicate = @user.orders.build(status: "pending", total_cents: 0, stripe_session_id: "cs_test_1")
    assert_not duplicate.valid?
  end
end
