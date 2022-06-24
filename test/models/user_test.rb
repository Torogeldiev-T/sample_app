require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'Example User', email: 'user@example.com', password: 'somepwd1',
                     password_confirmation: 'somepwd1')
    @u = User.new(name: 'Tilek', email: 'TILEK@main.org', password: 'somepwd1', password_confirmation: 'somepwd1')
  end

  test 'authenticated? should return false for a user with nil digest' do
    assert_not @user.authenticated?(:remember, '')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = '     '
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = '     '
    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test 'email should not be too long' do
    @user.email = 'a' * 244 + '@example.com'
    assert_not @user.valid?
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'email addresses should be unique' do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email downcast should work' do
    assert_equal @u.email, 'TILEK@main.org'
    @u.save
    assert_equal @u.email, 'tilek@main.org'
  end

  test 'password should be present (nonblank)' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test 'associated microposts should be destroyed' do
    @user.save
    @user.microposts.create!(content: 'Lorem ipsum')
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test 'should follow and unfollow a user' do
    tilek = users(:tilek)
    archer  = users(:archer)
    assert_not tilek.following?(archer)
    tilek.follow(archer)
    assert tilek.following?(archer)
    assert archer.followers.include?(tilek)
    tilek.unfollow(archer)
    assert_not tilek.following?(archer)
    assert_nil tilek.active_relationships.find_by(followed_id: archer)
    # Users can't follow themselves.
    tilek.follow(tilek)
    assert_not tilek.following?(tilek)
  end

  test 'feed should have the right posts' do
    tilek = users(:tilek)
    archer  = users(:archer)
    lana    = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert tilek.feed.include?(post_following)
    end
    # Self-posts for user with followers
    tilek.microposts.each do |post_self|
      assert tilek.feed.include?(post_self)
    end
    # Posts from non-followed user
    archer.microposts.each do |post_unfollowed|
      assert_not tilek.feed.include?(post_unfollowed)
    end
  end
end
