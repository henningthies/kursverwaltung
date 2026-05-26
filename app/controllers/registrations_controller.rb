class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  layout "auth"

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.role = "learner"

    if @user.save
      log_in(@user)
      redirect_to after_login_url, notice: "Willkommen, #{@user.name}!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def registration_params
      params.expect(user: %i[name email password password_confirmation])
    end
end
