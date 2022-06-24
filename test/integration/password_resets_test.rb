require 'test_helper'

class PasswordResets < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class PasswordResetForm < PasswordResets
  def setup
    super
    @user = users(:tilek)
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end

class ForgotPasswordFormTest < PasswordResets
  test 'should render password_resets/new path' do
    get new_password_reset_url
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  test 'should rerender when invalid email submitted' do
    post password_resets_path, params: { password_reset: { email: '' } }
    assert_response :unprocessable_entity
    assert_nil flash[:info]
    assert_template 'password_resets/new'
  end
end

class PasswordFormTest < PasswordResetForm
  test 'post vith valid email address' do
    assert @reset_user.reset_digest
    assert flash[:info]
    assert_redirected_to root_path
  end

  test 'reset with wrong email in url' do
    get edit_password_reset_path(@reset_user.reset_token, email: '')
    assert_redirected_to root_path
  end

  test 'reset with inactive user' do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_redirected_to root_url
  end

  test 'reset with right email but wrong token' do
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    assert_redirected_to root_url
  end

  test 'reset with right email and right token' do
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name=email][type=hidden][value=?]', @reset_user.email
  end
end

class PasswordUpdateTest < PasswordResetForm
  test 'update with invalid password and confirmation' do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: 'foobaz',
                            password_confirmation: 'barquux' } }
    assert_select 'div#error-explanation'
  end

  test 'update with empty password' do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: '',
                            password_confirmation: '' } }
    assert_select 'div#error-explanation'
  end

  test 'update with valid password and confirmation' do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: 'foobaz',
                            password_confirmation: 'foobaz' } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user
    @reset_user.reload
    assert_nil @reset_user.reset_digest
  end
end

class ExpiredToken < PasswordResetForm
  def setup
    super
    # Create a password-reset token.
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
    # Expire the token by hand.
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    # Attempt to update the user's password.
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: 'foobar',
                            password_confirmation: 'foobar' } }
  end
end

class ExpiredTokenTest < ExpiredToken
  test 'should redirect to the password-reset page' do
    assert_redirected_to new_password_reset_url
  end

  test "should include the word 'expired' on the password-reset page" do
    follow_redirect!
    assert_match(/expired/i, response.body)
  end
end
