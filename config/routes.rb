Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config.merge(
    controllers: {
      sessions: "active_admin/devise/sessions",
      passwords: "active_admin/devise/passwords",
    },
  )
  ActiveAdmin.routes(self)

  root "products#index"

  resources :users
  resources :products, only: [:index, :show]
  resources :categories
  resources :orders, only: [:index, :show]

  get "about", to: "pages#about", as: :about
  get "contact", to: "pages#contact", as: :contact

  get "up" => "rails/health#show", as: :rails_health_check
end
