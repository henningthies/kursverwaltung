# Dünner Wrapper um Stripe Checkout. Hält die Stripe-Aufrufe an einer Stelle, damit
# Controller test-freundlich bleiben (in Tests gestubbt) und die App ohne Keys nicht
# abstürzt. Siehe ADR 0006.
module PaymentGateway
  class NotConfigured < StandardError; end

  module_function

  # Keys aus Credentials (stripe.secret_key) oder ENV (STRIPE_SECRET_KEY).
  def secret_key
    Rails.application.credentials.dig(:stripe, :secret_key) || ENV["STRIPE_SECRET_KEY"]
  end

  def webhook_secret
    Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV["STRIPE_WEBHOOK_SECRET"]
  end

  def configured?
    secret_key.present?
  end

  # Erzeugt eine Stripe-Checkout-Session für den Order. Wirft NotConfigured ohne Keys,
  # damit der Checkout-Pfad eine klare Meldung zeigen kann statt zu crashen.
  def create_checkout_session(order:, success_url:, cancel_url:)
    raise NotConfigured unless configured?

    Stripe.api_key = secret_key
    Stripe::Checkout::Session.create(
      mode: "payment",
      success_url: success_url,
      cancel_url: cancel_url,
      client_reference_id: order.id.to_s,
      line_items: order.order_items.map { |item| line_item(item) }
    )
  end

  # Verifiziert die Webhook-Signatur und gibt das Stripe-Event zurück.
  def construct_event(payload, signature_header)
    raise NotConfigured if webhook_secret.blank?

    Stripe::Webhook.construct_event(payload, signature_header, webhook_secret)
  end

  def line_item(item)
    {
      quantity: 1,
      price_data: {
        currency: "eur",
        unit_amount: item.price_cents,
        product_data: { name: item.course.title }
      }
    }
  end
end
