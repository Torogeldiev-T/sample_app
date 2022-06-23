require 'test_helper'

class MicropostsInterface < ActionDispatch::IntegrationTest
  def setup
    @user = users(:tilek)
    log_in_as(@user)
  end
end

class ImageUploadTest < MicropostsInterface
  test 'should have a file input field for images' do
    get root_path
    assert_select 'input[type=file]'
  end

  test 'should be able to attach an image' do
    cont = 'This micropost really ties the room together.'
    img  = fixture_file_upload('kitten.jpg', 'image/jpeg')
    post microposts_path, params: { micropost: { content: cont, image: img } }
    @micropost = assigns(:micropost)
    assert @micropost.image.attached?
  end
end
