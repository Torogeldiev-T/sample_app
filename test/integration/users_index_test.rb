require 'test_helper'

class UsersIndex < ActionDispatch::IntegrationTest
  def setup
    @admin     = users(:tilek)
    @non_admin = users(:archer)
  end
end

class AmdminUsersIndex < UsersIndex
  def setup
    super
    log_in_as(@admin)
    get users_path
  end
end

class NonAmdminUsersIndex < UsersIndex
  def setup
    super
    log_in_as(@non_admin)
    get users_path
  end
end

class AmdminUsersIndexTest < AmdminUsersIndex
  test 'should render users/index' do
    assert_template 'users/index'
  end

  test 'should return pagination' do
    assert_select 'div.pagination'
  end

  test 'should have delete links' do
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      assert_select 'a[href=?]', user_path(user), text: 'delete' unless user == @admin
    end
  end

  test 'should delete user' do
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end

  # test 'should display only activated users' do
  #   # Deactivate the first user on the page.
  #   # Making an inactive fixture user isn't sufficient because Rails can't
  #   # guarantee it would appear on the first page.
  #   User.paginate(page: 1).first.toggle!(users(:not_active))
  #   # Ensure that all the displayed users are activated.
  #   assigns(:users).each do |user|
  #     assert user.activated?
  #   end
  # end
end

class NonAmdminUsersIndexTest < NonAmdminUsersIndex
  test 'index as non-admin' do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
