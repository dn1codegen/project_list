class ProjectFile < ApplicationRecord
  belongs_to :project
  has_one_attached :file

  validates :file_type, presence: true

  after_commit :touch_project, on: [ :create, :update, :destroy ]

  # Методы для определения типа файла
  def image?
    file.variable?
  end

  def text_file?
    return false unless file.attached?
    return true if file.content_type&.start_with?("text/")
    return true if file.filename&.to_s&.end_with?(".txt", ".md", ".log", ".rst")
    false
  end

  def document_file?
    !image? && !text_file?
  end

  private

  def touch_project
    project&.touch
  end
end
