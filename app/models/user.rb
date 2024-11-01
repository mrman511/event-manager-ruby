class User < ApplicationRecord
  has_secure_password

  has_many :hostings
  has_many :hosts, through: :hostings

  before_save :downcase_email

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true, uniqueness: true
  validates :password, length: { minimum: 8, maximum: 72 }
  validate :password_requirements_are_met

  private

  def downcase_email
    self.email = email.downcase
  end

  def password_requirements_are_met
    rules = {
      " must contain at least one lowercase letter"  => /[a-z]+/,
      " must contain at least one uppercase letter"  => /[A-Z]+/,
      " must contain at least one digit"             => /\d+/,
      " must contain at least one special character" => /[^A-Za-z0-9]+/
    }

    rules.each do |message, regex|
      errors.add(:password, message) unless password.match(regex)
    end
  end
end
