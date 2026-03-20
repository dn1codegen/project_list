class ProjectView < ApplicationRecord
  belongs_to :access_log
  belongs_to :project

  scope :recent, -> { order(viewed_at: :desc) }
  scope :by_project, ->(project) { where(project: project) }
  scope :by_access_log, ->(log) { where(access_log: log) }
end
