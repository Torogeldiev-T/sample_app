class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        forwarding_url = session[:forwarding_url]
        reset_session
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        log_in(user)
        redirect_to forwarding_url || user
      else
        message = 'Account not activated. Check your email for the activation link.'
        flash[:warning] = message
        redirect_to root_path
      end

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
