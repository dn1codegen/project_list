class ProjectsController < ApplicationController
  before_action :require_web_token, except: :track_exit
  before_action :log_access, except: :track_exit
  before_action :set_project, only: [ :show ]
  skip_before_action :verify_authenticity_token, only: :track_exit

  def index
    @projects = Project.search(params[:search]).sort_by(&:updated_at).reverse
    setup_visit_tracking
    @web_access_key_name = @web_access_key&.name
  end

  def show
    setup_visit_tracking
    log_project_view
    @web_access_key_name = @web_access_key&.name
  end

  def track_exit
    access_log = AccessLog.find_by(id: params[:access_log_id])
    return unless access_log

    duration = ((Time.current - access_log.entered_at).to_i).abs
    access_log.update(
      exited_at: Time.current,
      duration: duration
    )
    head :ok
  end

  protect_from_forgery except: :track_exit

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def setup_visit_tracking
    return if session[:admin_id] || cookies[:admin_remember_token]

    @track_visit = true
    @access_log_id = session[:access_log_id]
  end

  def log_project_view
    return if session[:admin_id] || cookies[:admin_remember_token]
    return unless @access_log_id && @project

    access_log = AccessLog.find_by(id: @access_log_id)
    return unless access_log

    ProjectView.create(
      access_log: access_log,
      project: @project,
      viewed_at: Time.current
    )
  end
end
