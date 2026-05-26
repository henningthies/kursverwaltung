class CartsController < ApplicationController
  layout "marketplace"

  def show
    @cart = current_cart
  end

  def add
    cart = current_cart
    cart.add(params[:course_id])
    session[:cart_course_ids] = cart.course_ids
    redirect_to cart_path, notice: "Zum Warenkorb hinzugefügt."
  end

  def remove
    cart = current_cart
    cart.remove(params[:course_id])
    session[:cart_course_ids] = cart.course_ids
    redirect_to cart_path, notice: "Aus dem Warenkorb entfernt."
  end

  private
    def current_cart
      Cart.new(session[:cart_course_ids])
    end
end
