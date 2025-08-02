ActiveAdmin.register Order do
  # Only permit status changes
  permit_params :status

  # Index page - show orders with key information
  index do
    selectable_column
    id_column
    column :user do |order|
      order.user.name if order.user
    end
    column :order_date
    column :status do |order|
      status_tag order.status.humanize, class: case order.status
                                               when 'pending' then 'warning'
                                               when 'completed' then 'ok'
                                               when 'shipped' then 'yes'
                                               when 'cancelled' then 'error'
                                               else 'default'
                                               end
    end
    column :grand_total do |order|
      number_to_currency(order.grand_total)
    end
    actions
  end

  # Form - only allow status editing
  form do |f|
    f.inputs "Order Status" do
      f.input :status, as: :select, 
              collection: [
                ['Pending', 'pending'],
                ['Processing', 'processing'], 
                ['Shipped', 'shipped'],
                ['Completed', 'completed'],
                ['Cancelled', 'cancelled']
              ],
              prompt: 'Select Status'
    end
    f.actions
  end

  # Filters
  filter :status, as: :select, collection: [
    ['Pending', 'pending'],
    ['Processing', 'processing'], 
    ['Shipped', 'shipped'],
    ['Completed', 'completed'],
    ['Cancelled', 'cancelled']
  ]
  filter :order_date
  filter :grand_total

  # Scopes for quick filtering
  scope :all
  scope("Pending") { |scope| scope.where(status: 'pending') }
  scope("Processing") { |scope| scope.where(status: 'processing') }
  scope("Shipped") { |scope| scope.where(status: 'shipped') }
  scope("Completed") { |scope| scope.where(status: 'completed') }
  scope("Cancelled") { |scope| scope.where(status: 'cancelled') }
end