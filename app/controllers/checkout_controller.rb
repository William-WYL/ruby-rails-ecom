class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_not_empty
  before_action :ensure_user_has_address, only: [:new, :create]

  def new
    @order = Order.new
    @cart_items = @current_cart.cart_items
    @subtotal = @current_cart.total_price
    @tax_rate = current_user.address.province.total_tax_rate
    @tax_amount = @subtotal * @tax_rate
    @total = @subtotal + @tax_amount
  end

  def create
    @order = build_order
    
    if @order.save
      create_order_items
      @current_cart.clear
      save_cart
      redirect_to order_path(@order), notice: 'Order placed successfully!'
    else
      @cart_items = @current_cart.cart_items
      @subtotal = @current_cart.total_price
      @tax_rate = current_user.address.province.total_tax_rate
      @tax_amount = @subtotal * @tax_rate
      @total = @subtotal + @tax_amount
      render :new, status: :unprocessable_entity
    end
  end

  private

  def ensure_cart_not_empty
    if @current_cart.empty?
      redirect_to cart_path, alert: 'Your cart is empty!'
    end
  end

  def ensure_user_has_address
    unless current_user.address
      redirect_to edit_user_registration_path, 
                  alert: 'Please add your address before checkout.'
    end
  end

  def build_order
    subtotal = @current_cart.total_price
    province = current_user.address.province
    
    # Calculate taxes
    gst = subtotal * province.gst
    pst = subtotal * province.pst  
    hst = subtotal * province.hst
    total_tax = gst + pst + hst
    grand_total = subtotal + total_tax

    current_user.orders.build(
      address: current_user.address,
      province: province,
      subtotal: subtotal,
      total_tax: total_tax,
      grand_total: grand_total,
      total: grand_total, # For backward compatibility
      order_date: Time.current,
      status: 'pending'
    )
  end

  def create_order_items
    @current_cart.cart_items.each do |item|
      product = item[:product]
      quantity = item[:quantity]
      unit_price = product.price
      
      # Calculate taxes for this item
      province = @order.province
      gst_amount = unit_price * quantity * province.gst
      pst_amount = unit_price * quantity * province.pst
      hst_amount = unit_price * quantity * province.hst
      
      @order.order_items.create!(
        product: product,
        quantity: quantity,
        unit_price: unit_price,
        applied_gst: gst_amount,
        applied_pst: pst_amount,
        applied_hst: hst_amount
      )
    end
  end
end
