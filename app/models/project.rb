class Project < ApplicationRecord
  has_many :project_files, dependent: :destroy
  has_many :project_views, dependent: :destroy

  # Backward compatibility - оставляем старые отношения для существующих проектов
  has_many :measurements, -> { where(file_type: "measurement") }, class_name: "ProjectFile"
  has_many :examples, -> { where(file_type: "example") }, class_name: "ProjectFile"
  has_one :project_pdf, -> { where(file_type: "project_pdf") }, class_name: "ProjectFile"

  validates :name, presence: true
  validates :customer, presence: true
  validates :address, presence: true
  validates :sku, presence: true, uniqueness: true

  after_update_commit :increment_updates_count

  def self.search(keyword)
    return all if keyword.blank?

    terms = keyword.split(/\s+/).reject(&:blank?)
    return all if terms.empty?

    # Always filter in Ruby for Unicode case-insensitive matching
    all.to_a.select do |project|
      terms.all? do |term|
        project.name.downcase.include?(term.downcase) ||
        project.customer&.downcase&.include?(term.downcase) ||
        project.address&.downcase&.include?(term.downcase) ||
        project.sku&.downcase&.include?(term.downcase)
      end
    end
  end

  def self.find_or_initialize_by_sku(sku)
    find_by(sku: sku) || new(sku: sku)
  end

  def increment_updates_count
    update_column(:updates_count, updates_count + 1)
  end

  # Универсальные методы для работы с файлами по типу
  def files_by_type(type)
    project_files.where(file_type: type)
  end

  def single_file_by_type(type)
    project_files.find_by(file_type: type)
  end

  # Получить все уникальные типы файлов (папки)
  def file_types
    project_files.pluck(:file_type).uniq
  end

  # Получить файлы сгруппированные по типам
  def files_grouped_by_type
    project_files.group_by(&:file_type)
  end
end
