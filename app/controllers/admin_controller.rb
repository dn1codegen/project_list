class AdminController < ApplicationController
  before_action :authenticate_admin!, except: [ :login ]

  def dashboard
    @web_access_keys = WebAccessKey.all.order(created_at: :desc)
    @project_keys = ProjectKey.all.order(created_at: :desc)
  end

  def login
    if request.post?
      admin = Admin.find_by(email: params[:email])
      if admin&.authenticate(params[:password])
        session[:admin_id] = admin.id

        if params[:remember_me] == "1"
          token = SecureRandom.hex(32)
          cookies.permanent[:admin_remember_token] = token
          admin.update(remember_token: token)
        end

        redirect_to admin_dashboard_path, notice: "Вход выполнен"
      else
        flash.now[:alert] = "Неверный email или пароль"
      end
    end
  end

  def logout
    session[:admin_id] = nil
    cookies.delete(:admin_remember_token)
    if current_admin
      current_admin.update(remember_token: nil)
    end
    redirect_to admin_login_path, notice: "Выход выполнен"
  end

  def settings
    if request.patch?
      if current_admin.update(admin_params)
        redirect_to admin_settings_path, notice: "Настройки сохранены"
      else
        flash.now[:alert] = "Ошибка при сохранении"
      end
    end
  end

  private

  def admin_params
    params.require(:admin).permit(:email, :password, :password_confirmation)
  end

  def authenticate_admin!
    unless session[:admin_id]
      redirect_to admin_login_path, alert: "Необходима авторизация"
    end
  end
end
