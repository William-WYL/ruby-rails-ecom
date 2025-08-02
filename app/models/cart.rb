class Cart
  attr_reader :items

  # Class method to build a cart from a hash (for session loading)
  def self.build_from_hash(hash)
    new(hash)
  end

  # Initialize the cart with a hash from the session or empty by default
  def initialize(session_cart = {})
    session_cart ||= {}
    @items = session_cart.fetch("items", {})
  end

  # Add a product to the cart or increase its quantity
  def add_item(product_id, quantity = 1)
    product_id = product_id.to_s
    if @items[product_id]
      @items[product_id] += quantity.to_i
    else
      @items[product_id] = quantity.to_i
    end
    # Ensure quantity is at least 1
    @items[product_id] = [@items[product_id], 1].max
  end

  # Update the quantity of a product in the cart
  # If quantity is zero or less, remove the item
  def update_quantity(product_id, quantity)
    product_id = product_id.to_s
    quantity = quantity.to_i

    if quantity <= 0
      remove_item(product_id)
    else
      @items[product_id] = quantity
    end
  end

  # Remove a product from the cart
  def remove_item(product_id)
    @items.delete(product_id.to_s)
  end

  # Return the total number of items in the cart
  def total_items
    @items.values.sum
  end

  # Calculate the total price of all items in the cart
  def total_price
    cart_products = Product.where(id: @items.keys)
    @items.sum do |product_id, quantity|
      product = cart_products.find { |p| p.id == product_id.to_i }
      product ? product.price * quantity : 0
    end
  end

  # Return detailed information for each cart item
  # Includes product object, quantity, and subtotal price
  def cart_items
    return [] if @items.empty?

    cart_products = Product.where(id: @items.keys)
    @items.map do |product_id, quantity|
      product = cart_products.find { |p| p.id == product_id.to_i }
      next unless product

      {
        product: product,
        quantity: quantity,
        subtotal: product.price * quantity,
      }
    end.compact
  end

  # Check if the cart is empty
  def empty?
    @items.empty?
  end

  # Clear all items from the cart
  def clear
    @items.clear
  end

  # Convert cart data to a hash for storing in session
  def to_hash
    { "items" => @items }
  end
end
