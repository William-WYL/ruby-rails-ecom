Rails.application.routes.draw do
  root "products#index"

  devise_for :admin_users, ActiveAdmin::Devise.config.merge(
    controllers: {
      sessions: "active_admin/devise/sessions",
      passwords: "active_admin/devise/passwords",
    },
  )
  ActiveAdmin.routes(self)

  resources :users
  resources :products, only: [:index, :show]
  resources :categories
  resources :orders, only: [:index, :show]

  get "about", to: "pages#about"
  get "up" => "rails/health#show", as: :rails_health_check
end
