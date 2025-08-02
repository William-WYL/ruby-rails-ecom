class Cart
  attr_reader :items

  def initialize(session_cart = {})
    session_cart ||= {}
    @items = session_cart.fetch("items", {})
  end

  def add_item(product_id, quantity = 1)
    product_id = product_id.to_s
    if @items[product_id]
      @items[product_id] += quantity.to_i
    else
      @items[product_id] = quantity.to_i
    end
    @items[product_id] = [@items[product_id], 1].max # Ensure minimum quantity is 1
  end

  def update_quantity(product_id, quantity)
    product_id = product_id.to_s
    quantity = quantity.to_i

    if quantity <= 0
      remove_item(product_id)
    else
      @items[product_id] = quantity
    end
  end

  def remove_item(product_id)
    @items.delete(product_id.to_s)
  end

  def total_items
    @items.values.sum
  end

  def total_price
    cart_products = Product.where(id: @items.keys)
    @items.sum do |product_id, quantity|
      product = cart_products.find { |p| p.id == product_id.to_i }
      product ? product.price * quantity : 0
    end
  end

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

  def empty?
    @items.empty?
  end

  def clear
    @items.clear
  end

  def to_hash
    { "items" => @items }
  end
end
