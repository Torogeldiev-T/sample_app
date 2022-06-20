module UsersHelper
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5.hexdigest(user.email)
    gravatar_url = "https://robohash.org/#{gravatar_id}"
    size = options[:size]
    image_tag(gravatar_url, alt: user.name, class: 'gravatar', size:)
  end
end
