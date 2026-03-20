class AccessLog < ApplicationRecord
  belongs_to :web_access_key
  has_many :project_views, dependent: :destroy

  scope :recent, -> { order(entered_at: :desc) }
  scope :by_key, ->(key) { where(web_access_key: key) }
  scope :active, -> { where(exited_at: nil) }
  scope :completed, -> { where.not(exited_at: nil) }

  def unique_projects_viewed
    project_views.pluck(:project_id).uniq.count
  end
end
