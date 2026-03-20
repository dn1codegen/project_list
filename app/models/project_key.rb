class ProjectKey < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(active: true) }

  before_validation :generate_key, on: :create

  after_initialize :set_default_active, if: :new_record?

  def set_default_active
    self.active = true if active.nil?
  end

  def toggle_active!
    update!(active: !active)
  end

  def generate_key
    self.key ||= SecureRandom.hex(32)
  end
end
