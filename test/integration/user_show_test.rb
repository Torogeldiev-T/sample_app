require 'test_helper'

class UserShowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:not_active)
  end

  test 'should not dispaly user' do
    get user_path(@user)
    assert_redirected_to root_path
  end
end
