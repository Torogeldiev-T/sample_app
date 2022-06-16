require "test_helper"
class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path

  end
  
  test "visit sign up page" do
    get signup_path
    assert_template 'users/new'
    assert_select 'title', 'Sign Up | Ruby on Rails Tutorial Sample App'
  
  end
end

