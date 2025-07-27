# app/models/order_status.rb
class OrderStatus < ApplicationRecord
  belongs_to :order

  validates :status, presence: true
end
