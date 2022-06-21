require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
  test 'invalid signup path' do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '',
                                         email: 'user@valid.com',
                                         password: 'foobar',
                                         password_confirmation: 'foobar' } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div.alert.alert-danger', 'The form contains 1 error'
  end

  test 'valid signup path' do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: 'Valid Name',
                                         email: 'exmpl@valid.com',
                                         password: 'foobar',
                                         password_confirmation: 'foobar' } }
    end
    follow_redirect!
    # assert_template 'users/show'
    # assert is_logged_in?
    # assert flash[:success]
  end
end
