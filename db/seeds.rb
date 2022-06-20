User.create!(name: 'Admin User',
             email: 'admin@gmail.com',
             password: 'foobar',
             password_confirmation: 'foobar',
             admin: true)

# Generate a bunch of additional users.
99.times do |_n|
  name = Faker::Name.name
  email = "example-#{_n}@railstutorial.org"
  password = 'password'
  User.create!({ "name": name, "email": email, "password": password, password_confirmation: password })
end
