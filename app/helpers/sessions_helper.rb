module SessionsHelper
  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
    # Guard against session replay attacks.
    # See https://bit.ly/33UvK0w for more.
    session[:session_token] = user.session_token
  end

  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      @current_user = user if user && session[:session_token] == user.session_token
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # forgets a permanenent session
  def forget(user)
    user.forget
    cookies[:user_id] = nil
    cookies[:remember_token] = nil
  end

  def log_out
    forget(current_user)
    reset_session
    session[:user_id] = nil
  end
end
