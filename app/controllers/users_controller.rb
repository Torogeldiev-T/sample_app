class UsersController < ApplicationController
  before_action :logged_in_user, only: %i[index edit update destroy]
  before_action :correct_user,   only: %i[edit update]
  before_action :admin_user, only: %i[destroy]
  def new
    @user = User.new
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = 'Check your email to activate your account.'
      redirect_to root_path
      # or use
      # redirect_to user_url(@user)
      # which are equeqvalient
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      # handle a successfull update
      flash[:success] = 'Profile updated'
      redirect_to @user

    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params['id']).destroy
    flash[:success] = 'User deleted'
    redirect_to users_path, status: :see_other
  end

  private

  # Strong parameters
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = 'Please log in.'
      redirect_to login_path, status: :see_other
    end
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_path, status: :see_other) unless current_user.admin?
  end
end
