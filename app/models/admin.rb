class Admin < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :remember_token, uniqueness: true, allow_nil: true

  validates :password, presence: true, confirmation: true, on: :create
  validates :password_confirmation, presence: true, on: :create
end
