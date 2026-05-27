module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_login
    helper_method :current_user, :logged_in?
  end

  class_methods do
    # In Controllern, die ohne Login erreichbar sein müssen (Katalog, Login, Registrierung).
    def allow_unauthenticated_access(**options)
      skip_before_action :require_login, **options
    end
  end

  private
    def current_user
      Current.user ||= User.find_by(id: session[:user_id])
    end

    def logged_in?
      current_user.present?
    end

    def require_login
      return if logged_in?

      session[:return_to_after_login] = request.url if request.get?
      redirect_to new_session_path, alert: "Bitte melde dich an."
    end

    def require_admin
      return if current_user&.admin?

      redirect_to root_path, alert: "Dieser Bereich ist nur für Administratoren."
    end

    # Session-Fixation vermeiden: bei Login die Session zurücksetzen, Warenkorb erhalten.
    def log_in(user)
      cart = session[:cart_course_ids]
      reset_session
      session[:cart_course_ids] = cart if cart.present?
      session[:user_id] = user.id
      Current.user = user
    end

    def log_out
      reset_session
      Current.user = nil
    end

    def after_login_url
      session.delete(:return_to_after_login) || root_path
    end
end
