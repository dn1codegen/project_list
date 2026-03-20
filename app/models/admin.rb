class Admin < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :remember_token, uniqueness: true, allow_nil: true
end
