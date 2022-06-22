class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_save :downcase_email
  before_create :create_activation_token
  validates :name, presence: true, length: { maximum: 50 }

  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # Returns the hash digest of the given string.
  def self.digest(string)
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string)
  end

  # generate new token with 64 posiible characters per token char
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    # set remember token and then update remember_digest with encrypted remember token
    # with User.digest method that encrypts remember token
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def session_token
    remember_digest || remember
  end

  # forgets a user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # verify that remember token matches remember_digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    # bcrypt overrides == operator by hashing remember_token string to digest
    # and then compares remember_digest and hashed remember_token
    BCrypt::Password.new(digest) == token
  end

  # Activates an account.
  def activate
    # update_attribute(:activated,    true)
    # update_attribute(:activated_at, Time.zone.now)

    # or
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    # update_attribute(:reset_digest,  User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Checks if password reset has expired
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def create_activation_token
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
