class CartController < ApplicationController
  def show
    @cart_items = @current_cart.cart_items
  end

  def add_item
    product = Product.find(params[:product_id])
    quantity = params[:quantity]&.to_i || 1
    
    @current_cart.add_item(product.id, quantity)
    save_cart
    
    redirect_back(fallback_location: product_path(product), 
                  notice: "#{product.title} added to cart!")
  end

  def update_item
    product_id = params[:product_id]
    quantity = params[:quantity].to_i
    
    if quantity > 0
      @current_cart.update_quantity(product_id, quantity)
      save_cart
      redirect_to cart_path, notice: "Cart updated successfully!"
    else
      remove_item
    end
  end

  def remove_item
    product_id = params[:product_id] || params[:id]
    product = Product.find(product_id)
    
    @current_cart.remove_item(product_id)
    save_cart
    
    redirect_to cart_path, notice: "#{product.title} removed from cart!"
  end

  def clear
    @current_cart.clear
    session.delete(:cart)  # Completely remove from session
    save_cart
    redirect_to cart_path, notice: "Your cart has been cleared."
  end

  def reset_session
    session.delete(:cart)
    redirect_to cart_path, notice: "Cart session has been reset."
  end
end
