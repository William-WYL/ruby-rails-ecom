Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config.merge(
    controllers: {
      sessions: "active_admin/devise/sessions",
      passwords: "active_admin/devise/passwords",
    },
  )
  ActiveAdmin.routes(self)

  devise_for :users, path: "", path_names: {
                       sign_in: "login",
                       sign_out: "logout",
                       sign_up: "register",
                     }, skip: [:registrations]

  devise_scope :user do
    resource :registration,
      only: [:new, :create, :edit, :update],
      path: "users",
      path_names: { new: "register" },
      controller: "users/registrations",
      as: :user_registration
  end

  root "products#index"

  resources :users, only: [:index, :show]

  resources :products, only: [:index, :show]
  resources :categories
  resources :orders, only: [:index, :show]

  # Shopping cart routes
  get "cart", to: "cart#show"
  post "cart/add/:product_id", to: "cart#add_item", as: "add_to_cart"
  patch "cart/:product_id", to: "cart#update_item", as: "update_cart_item"
  delete "cart/:product_id", to: "cart#remove_item", as: "remove_from_cart"
  delete "cart", to: "cart#clear", as: "clear_cart"
  get "cart/reset", to: "cart#reset_session", as: "reset_cart_session"

  # Checkout routes
  get "checkout", to: "checkout#new", as: "new_checkout"
  post "checkout", to: "checkout#create", as: "checkout"

  get "about", to: "pages#about", as: :about
  get "contact", to: "pages#contact", as: :contact

  get "up" => "rails/health#show", as: :rails_health_check
end
