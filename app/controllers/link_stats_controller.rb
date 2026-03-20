class LinkStatsController < ApplicationController
  before_action :require_admin!

  def show
    @web_access_key = WebAccessKey.find(params[:id])

    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 7.days.ago.to_date
    @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today

    @project_stats = calculate_project_stats
  end

  private

  def calculate_project_stats
    stats = {}

    ProjectView.joins(:access_log).where(
      access_logs: { web_access_key: @web_access_key },
      viewed_at: @start_date.beginning_of_day..@end_date.end_of_day
    ).group(:project_id).count.each do |project_id, views_count|
      project = Project.find(project_id)

      logs_with_project = AccessLog.joins(:project_views).where(
        web_access_key: @web_access_key,
        entered_at: @start_date.beginning_of_day..@end_date.end_of_day,
        project_views: { project_id: project_id }
      )

      total_duration = logs_with_project.where.not(duration: nil).sum(:duration)

      last_view_date = ProjectView.joins(:access_log).where(
        access_logs: { web_access_key: @web_access_key },
        project_id: project_id
      ).maximum(:viewed_at)

      stats[project] = {
        views_count: views_count,
        duration: total_duration,
        last_viewed_at: last_view_date
      }
    end

    stats.sort_by { |_, data| -data[:views_count] }.to_h
  end
end
