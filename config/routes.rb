Rails.application.routes.draw do
  get "link_stats/show"
  get "up" => "rails/health#show", as: :rails_health_check

  get "/link_stats/:id", to: "link_stats#show", as: :link_stats

  root "projects#index"

  resources :projects, only: [ :index, :show ]

  namespace :admin do
    get :dashboard
    get :login
    post :login
    delete :logout
    get :settings
    patch :settings
  end

  get "/admin", to: redirect("/admin/login")

  post "/track_exit", to: "projects#track_exit"

  resources :api_keys, only: [ :index ] do
    collection do
      post :create_web_access_key
      post :create_project_key
    end
    member do
      patch :toggle
      delete :destroy_web_access_key
      delete :destroy_project_key
    end
  end

  namespace :api do
    resources :projects, only: [ :create ]
  end
end
