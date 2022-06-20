class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      reset_session
      remember(user)
      log_in(user)
      redirect_to(user)
    else
      flash.now[:danger] = 'Invalid email or password given'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path, status: :see_other
  end
end
