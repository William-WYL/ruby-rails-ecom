class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Configure Devise parameters
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :current_cart

  protected

  def current_cart
    @current_cart ||= Cart.new(session[:cart])
  end

  def save_cart
    session[:cart] = @current_cart.to_hash
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, 
      address_attributes: [:street, :city, :postal_code, :province_id]
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name,
      address_attributes: [:id, :street, :city, :postal_code, :province_id, :_destroy]
    ])
  end
end
