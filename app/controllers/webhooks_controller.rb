# Stripe-Webhook. Öffentlich (kein Login), ohne CSRF (Stripe sendet ohne Token).
# Setzt den Order über die Stripe-Session-ID idempotent auf paid.
class WebhooksController < ApplicationController
  allow_unauthenticated_access only: %i[stripe]
  skip_forgery_protection only: %i[stripe]

  def stripe
    event = PaymentGateway.construct_event(request.body.read, request.headers["Stripe-Signature"])

    if event["type"] == "checkout.session.completed"
      fulfill(event["data"]["object"])
    end

    head :ok
  rescue PaymentGateway::NotConfigured
    head :service_unavailable
  rescue Stripe::SignatureVerificationError, JSON::ParserError
    head :bad_request
  end

  private
    def fulfill(checkout_session)
      # stripe_session_id wird vor dem Redirect zu Stripe gesetzt, daher matcht dieser
      # Lookup zuverlässig. Kein Fallback über extern kontrollierte Felder (client_reference_id).
      order = Order.find_by(stripe_session_id: checkout_session["id"])
      order&.mark_paid!
    end
end
