class WebAccessKey < ApplicationRecord
  has_many :access_logs, dependent: :destroy

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

  def total_visits
    access_logs.count
  end

  def active_sessions
    access_logs.active.count
  end

  def avg_duration
    logs = access_logs.completed
    return nil if logs.empty?
    (logs.sum(:duration) / logs.count).to_i
  end

  def total_project_views
    access_logs.joins(:project_views).count
  end

  def unique_projects_viewed
    access_logs.joins(:project_views).pluck("project_views.project_id").uniq.count
  end
end
