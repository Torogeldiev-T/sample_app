require 'test_helper'

class UsersLogin < ActionDispatch::IntegrationTest
  def setup
    @user = users(:tilek)
  end
end

class Validlogin < UsersLogin
  def setup
    super
    post login_path, params: { session: { email: @user.email, password: 'password' } }
  end
end

class LogOut < Validlogin
  def setup
    super
    delete logout_path
  end
end

class InvalidPasswordTest < UsersLogin
  test 'login path' do
    get login_path
    assert_template 'sessions/new'
  end

  test 'login with valid email/invalid password' do
    post login_path, params: { session: { email: 'tilek@gmail.com',
                                          password: 'invalid' } }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end

class ValidLoginTest < Validlogin
  test 'valid login' do
    assert is_logged_in?
    assert_redirected_to @user
  end
  test 'redirect after login' do
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
  end
end

class LogOutTest < LogOut
  test 'successful logout' do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_path
  end
  test 'redirect after logout' do
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', users_path(@user.id), count: 0
  end
  # Simulate a user clicking logout in a second window.
  test 'should work fater logout in the second window' do
    delete logout_path
    assert_redirected_to root_path
  end
end

class RememberingTest < UsersLogin
  test 'login with remembering' do
    log_in_as(@user, remember_me: '1')
    assert_not cookies[:remember_token].blank?
  end

  test 'login without remembering' do
    # Log in to set the cookie.
    log_in_as(@user, remember_me: '1')
    # Log in again and verify that the cookie is deleted.
    log_in_as(@user, remember_me: '0')
    assert cookies[:remember_token].blank?
  end
end
