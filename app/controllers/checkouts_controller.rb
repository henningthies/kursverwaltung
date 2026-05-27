class CheckoutsController < ApplicationController
  layout "marketplace"

  # Erzeugt einen pending Order aus dem Warenkorb und übergibt an Stripe Checkout.
  # Kostenlose Bestellungen (Summe 0) werden sofort als paid markiert (kein Checkout).
  def create
    cart = current_cart
    if cart.empty?
      redirect_to cart_path, alert: "Dein Warenkorb ist leer."
      return
    end

    order = current_user.orders.build(status: "pending")
    order.add_courses(cart.courses)
    order.save!
    session[:last_order_id] = order.id

    if order.total_cents.zero?
      order.mark_paid!
      clear_cart
      redirect_to success_checkout_path, notice: "Buchung bestätigt."
      return
    end

    session = PaymentGateway.create_checkout_session(
      order: order,
      success_url: success_checkout_url,
      cancel_url: cancel_checkout_url
    )
    order.update!(stripe_session_id: session.id)
    redirect_to session.url, allow_other_host: true
  rescue PaymentGateway::NotConfigured
    redirect_to cart_path, alert: "Bezahlung ist gerade nicht verfügbar. Bitte später erneut versuchen."
  end

  def success
    clear_cart
    @order = current_user.orders.find_by(id: session.delete(:last_order_id))
  end

  def cancel
    redirect_to cart_path, alert: "Bezahlung abgebrochen. Dein Warenkorb ist erhalten."
  end

  private
    def current_cart
      Cart.new(session[:cart_course_ids])
    end

    def clear_cart
      session.delete(:cart_course_ids)
    end
end
