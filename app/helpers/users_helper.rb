module UsersHelper
  def gravatar_for(user)
    gravatar_id = Digest::MD5.hexdigest(user.email)
    gravatar_url = "https://robohash.org/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, class: 'gravatar', size: 100)
  end
end
