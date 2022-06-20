require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:tilek)
  end

  test 'login with invalid information' do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: 'nonvalid@some.email.com', password: 'foobar' } }
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    assert flash['danger']
    get root_path
    assert_not flash['danger']
  end

  test 'login with valid information followed by logout' do
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)

    delete logout_path
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_path
    # Simulate a user clicking logout in a second window.
    delete logout_path
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', users_path(@user.id), count: 0
  end

  test 'login with valid email/invalid password' do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: 'tilek@gmail.com',
                                          password: 'invalid' } }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "should still work after logout in second window" do
    delete logout_path
    assert_redirected_to root_url
  end
end
