require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = users(:learner).orders.create!(
      status: "pending", total_cents: 4900, stripe_session_id: "cs_test_webhook"
    )
  end

  # Fixture-Payload eines checkout.session.completed-Events (kein echter Stripe-Call).
  def completed_event(session_id: "cs_test_webhook")
    {
      "type" => "checkout.session.completed",
      "data" => { "object" => { "id" => session_id, "client_reference_id" => nil } }
    }
  end

  def post_webhook(event)
    PaymentGateway.stub :construct_event, event do
      post webhooks_stripe_url, headers: { "Stripe-Signature" => "t=1,v1=fake" }
    end
  end

  test "completed event marks the matching order as paid" do
    post_webhook(completed_event)
    assert_response :ok
    assert @order.reload.paid?
  end

  test "duplicate completed event does not change paid_at (idempotent)" do
    post_webhook(completed_event)
    first_paid_at = @order.reload.paid_at
    travel 1.hour do
      post_webhook(completed_event)
    end
    assert_equal first_paid_at.to_i, @order.reload.paid_at.to_i
  end

  test "unrelated event type is ignored but acknowledged" do
    PaymentGateway.stub :construct_event, { "type" => "payment_intent.created", "data" => { "object" => {} } } do
      post webhooks_stripe_url, headers: { "Stripe-Signature" => "x" }
    end
    assert_response :ok
    assert_not @order.reload.paid?
  end

  test "missing webhook secret returns service unavailable" do
    PaymentGateway.stub :construct_event, ->(*) { raise PaymentGateway::NotConfigured } do
      post webhooks_stripe_url, headers: { "Stripe-Signature" => "x" }
    end
    assert_response :service_unavailable
  end

  test "invalid signature returns bad request" do
    PaymentGateway.stub :construct_event, ->(*) { raise Stripe::SignatureVerificationError.new("bad", "sig") } do
      post webhooks_stripe_url, headers: { "Stripe-Signature" => "bad" }
    end
    assert_response :bad_request
  end
end
