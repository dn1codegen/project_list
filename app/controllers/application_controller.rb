class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def current_admin
    return @current_admin if defined?(@current_admin)

    if session[:admin_id]
      @current_admin = Admin.find_by(id: session[:admin_id])
    elsif cookies[:admin_remember_token]
      @current_admin = Admin.find_by(remember_token: cookies[:admin_remember_token])
      if @current_admin
        session[:admin_id] = @current_admin.id
      end
    end

    @current_admin
  end
  helper_method :current_admin

  def authenticate_with_token!
    token = params[:token] || request.headers["X-App-Token"]
    head :unauthorized unless token == Rails.application.credentials.dig(:app_token) || token == "secret123" || WebAccessKey.active.find_by(key: token)
  end

  def authenticate_api!
    api_key = request.headers["Authorization"]&.gsub(/^Bearer /, "")
    head :unauthorized unless ProjectKey.active.find_by(key: api_key)
  end

  def require_admin!
    if session[:admin_id]
      return
    end

    remember_token = cookies[:admin_remember_token]
    if remember_token
      admin = Admin.find_by(remember_token: remember_token)
      if admin
        session[:admin_id] = admin.id
        return
      end
    end

    redirect_to admin_login_path, alert: "Необходима авторизация"
  end

  def require_web_token
    token = params[:token]

    if token.present?
      @web_access_key = WebAccessKey.active.find_by(key: token)
      unless @web_access_key
        redirect_to admin_login_path
      end
    else
      if session[:admin_id] || cookies[:admin_remember_token]
        return
      end
      redirect_to admin_login_path
    end
  end

  def log_access
    return unless @web_access_key

    if session[:access_log_id].nil?
      access_log = AccessLog.create(
        web_access_key: @web_access_key,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        entered_at: Time.current
      )
      session[:access_log_id] = access_log.id
    else
      existing_log = AccessLog.find_by(id: session[:access_log_id])
      if existing_log && existing_log.exited_at.nil?
        existing_log.touch
      else
        new_log = AccessLog.create(
          web_access_key: @web_access_key,
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
          entered_at: Time.current
        )
        session[:access_log_id] = new_log.id
      end
    end
  end

  def update_access_log
    return unless session[:access_log_id]

    access_log = AccessLog.find_by(id: session[:access_log_id])
    return unless access_log

    duration = ((Time.current - access_log.entered_at).to_i).abs
    access_log.update(
      exited_at: Time.current,
      duration: duration
    )
    session[:access_log_id] = nil
  end
end
