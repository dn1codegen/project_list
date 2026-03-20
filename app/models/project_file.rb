class ProjectFile < ApplicationRecord
  belongs_to :project
  has_one_attached :file

  validates :file_type, presence: true
  validates :file_type, inclusion: { in: %w[measurement example project_pdf] }

  after_commit :touch_project, on: [ :create, :update, :destroy ]

  private

  def touch_project
    project&.touch
  end
end
