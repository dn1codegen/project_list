class Admin < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :remember_token, uniqueness: true, allow_nil: true

  validates :password, presence: true, confirmation: true, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :password, confirmation: true, on: :update, if: :password_digest_changed?
  validates :password_confirmation, presence: true, on: :update, if: :password_digest_changed?
end
