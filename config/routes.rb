Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config.merge(
    controllers: {
      sessions: "active_admin/devise/sessions",
      passwords: "active_admin/devise/passwords",
    },
  )
  ActiveAdmin.routes(self)

  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'register'
  }, skip: [:registrations]
  
  devise_scope :user do
    resource :registration,
      only: [:new, :create, :edit, :update],
      path: 'users',
      path_names: { new: 'register' },
      controller: 'users/registrations',
      as: :user_registration
  end

  root "products#index"

  resources :users, only: [:index, :show]

  resources :products, only: [:index, :show]
  resources :categories
  resources :orders, only: [:index, :show]

  get "about", to: "pages#about", as: :about
  get "contact", to: "pages#contact", as: :contact

  get "up" => "rails/health#show", as: :rails_health_check
end
