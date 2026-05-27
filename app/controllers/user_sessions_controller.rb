# Login/Logout. Heißt UserSessionsController (nicht SessionsController), weil der
# vorhandene SessionsController bereits die Kurs-Termine (domain Session) verwaltet.
class UserSessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  layout "auth"

  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password])
      log_in(user)
      redirect_to after_login_url, notice: "Willkommen zurück, #{user.name}!"
    else
      flash.now[:alert] = "E-Mail oder Passwort ist falsch."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_path, notice: "Du wurdest abgemeldet."
  end
end
