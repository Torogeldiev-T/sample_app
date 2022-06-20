class User < ApplicationRecord
  attr_accessor :remember_token
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }

  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

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
  def User.new_token
    SecureRandom.urlsafe_base64
  end


  def remember
    # set remember token and then update remember_digest with encrypted remember token
    # with User.digest method that encrypts remember token 
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # forgets a user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # verify that remember token matches remember_digest
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    # bcrypt overrides == operator by hashing remember_token string to digest
    # and then compares remember_digest and hashed remember_token
    BCrypt::Password.new(remember_digest) == remember_token
  end
end
