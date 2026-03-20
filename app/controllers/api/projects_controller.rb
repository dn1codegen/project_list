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
    if params[:measurements]
      measurements_params = params[:measurements].to_unsafe_h.values
      measurements_params.each do |file_data|
        next if file_data[:file].nil?

        @project.project_files.create!(
          file_type: "measurement",
          description: file_data[:description],
          file: file_data[:file]
        )
      end
    end

    if params[:examples]
      examples_params = params[:examples].to_unsafe_h.values
      examples_params.each do |file_data|
        next if file_data[:file].nil?

        @project.project_files.create!(
          file_type: "example",
          description: file_data[:description],
          file: file_data[:file]
        )
      end
    end

    if params[:project_pdf]
      pdf_data = params[:project_pdf].to_unsafe_h
      @project.project_files.create!(
        file_type: "project_pdf",
        description: pdf_data[:description],
        file: pdf_data[:file]
      )
    end
  end
end
