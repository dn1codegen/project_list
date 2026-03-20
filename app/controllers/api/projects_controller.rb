class Api::ProjectsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]
  before_action :authenticate_api!, only: [ :create ]

  def create
    sku = params[:project][:sku]
    @project = Project.find_or_initialize_by_sku(sku)

    if @project.update(project_params)
      @project.project_files.destroy_all
      create_project_files
      status_code = @project.created_at == @project.updated_at ? :created : :ok
      render json: { success: true, project_id: @project.id, updated: !@project.created_at.equal?(@project.updated_at) }, status: status_code
    else
      render json: { success: false, errors: @project.errors }, status: :unprocessable_entity
    end
  end

  private

  def project_params
    params.require(:project).permit(:sku, :name, :customer, :address, :description)
  end

  def create_project_files
    # Универсальная обработка всех типов файлов
    if params[:files]
      params[:files].each do |folder_name, files_data|
        files_data = files_data.to_unsafe_h.values

        files_data.each do |file_data|
          next if file_data[:file].nil?

          # Используем имя папки как тип файла
          folder_name = file_data[:folder_name] || folder_name
          description = file_data[:description]

          @project.project_files.create!(
            file_type: folder_name,
            description: description,
            file: file_data[:file]
          )
        end
      end
    end
  end
end
