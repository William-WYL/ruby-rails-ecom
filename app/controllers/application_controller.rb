class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Configure Devise parameters
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Load or initialize the current cart before any action
  before_action :current_cart

  protected

  # Load the cart from session or create a new one
  def current_cart
    session[:cart] ||= {}
    session[:cart] = {} unless session[:cart].is_a?(Hash)
    @current_cart ||= Cart.build_from_hash(session[:cart])
  end

  # Save the current cart back into the session
  def save_cart
    session[:cart] = @current_cart.to_hash
  end

  # Permit additional parameters for Devise user sign up and account update
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
                                                  :name,
                                                  address_attributes: [:street, :city, :postal_code, :province_id],
                                                ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
                                                         :name,
                                                         address_attributes: [:id, :street, :city, :postal_code, :province_id, :_destroy],
                                                       ])
  end
end
