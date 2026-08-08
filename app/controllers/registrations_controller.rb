class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Account created. Welcome to Freelance Manager."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    attributes = registration_params
    password_changed = attributes[:password].present?

    if attributes[:password].blank?
      attributes.delete(:password)
      attributes.delete(:password_confirmation)
    end

    if @user.update(attributes)
      @user.sessions.where.not(id: Current.session.id).destroy_all if password_changed
      redirect_to edit_registration_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def registration_params
      params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
    end
end
