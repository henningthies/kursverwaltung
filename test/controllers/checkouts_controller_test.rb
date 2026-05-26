require "test_helper"

class CheckoutsControllerTest < ActionDispatch::IntegrationTest
  FakeSession = Struct.new(:id, :url)

  setup do
    @learner = users(:learner)
    sign_in_as(@learner)
  end

  def add_to_cart(course)
    post add_item_cart_url(course_id: course.id)
  end

  test "checkout requires login" do
    sign_out_via_logout
    post checkout_url
    assert_redirected_to new_session_url
  end

  test "empty cart cannot check out" do
    post checkout_url
    assert_redirected_to cart_url
  end

  test "paid checkout creates a pending order and redirects to Stripe" do
    add_to_cart(courses(:claude_code))
    fake = FakeSession.new("cs_test_123", "https://stripe.test/checkout/cs_test_123")

    PaymentGateway.stub :create_checkout_session, fake do
      assert_difference "Order.count", 1 do
        post checkout_url
      end
    end

    order = Order.last
    assert_equal "pending", order.status
    assert_equal "cs_test_123", order.stripe_session_id
    assert_equal 12900, order.total_cents
    assert_redirected_to "https://stripe.test/checkout/cs_test_123"
  end

  test "free-only cart is booked immediately without Stripe" do
    add_to_cart(courses(:free_intro))   # price 0

    assert_no_difference "Order.count" do
      # kein zweiter Stripe-Aufruf nötig; Order wird trotzdem erzeugt
    end
    assert_difference "Order.count", 1 do
      post checkout_url
    end
    order = Order.last
    assert order.paid?
    assert_redirected_to success_checkout_url
  end

  test "missing Stripe keys show a clear message instead of crashing" do
    add_to_cart(courses(:claude_code))

    PaymentGateway.stub :create_checkout_session, ->(*) { raise PaymentGateway::NotConfigured } do
      post checkout_url
    end
    assert_redirected_to cart_url
    follow_redirect!
    assert_select "p", text: /nicht verfügbar/
  end

  private
    def sign_out_via_logout
      delete session_url
    end
end
