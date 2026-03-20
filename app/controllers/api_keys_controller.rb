class ApiKeysController < ApplicationController
  before_action :require_admin!

  def index
    @web_access_keys = WebAccessKey.all.order(created_at: :desc)
    @project_keys = ProjectKey.all.order(created_at: :desc)
  end

  def toggle
    if params[:type] == "web_access"
      key = WebAccessKey.find(params[:id])
      key.toggle_active!
    else
      key = ProjectKey.find(params[:id])
      key.toggle_active!
    end
    redirect_to admin_dashboard_path, notice: "Статус изменен"
  end

  def create_web_access_key
    @key = WebAccessKey.new(name: params[:name])
    if @key.save
      redirect_to admin_dashboard_path, notice: "Ключ веб-доступа создан"
    else
      redirect_to admin_dashboard_path, alert: "Ошибка создания ключа"
    end
  end

  def create_project_key
    @key = ProjectKey.new(name: params[:name])
    if @key.save
      redirect_to admin_dashboard_path, notice: "Ключ для проектов создан"
    else
      redirect_to admin_dashboard_path, alert: "Ошибка создания ключа"
    end
  end

  def destroy_web_access_key
    key = WebAccessKey.find(params[:id])
    key.destroy
    redirect_to admin_dashboard_path, notice: "Ключ удален"
  end

  def destroy_project_key
    key = ProjectKey.find(params[:id])
    key.destroy
    redirect_to admin_dashboard_path, notice: "Ключ удален"
  end
end
