class Order < ApplicationRecord
  belongs_to :user
  belongs_to :address
  belongs_to :province

  has_many :order_items
  has_one :payment
  has_one :order_status

  validates :subtotal, :total_tax, :grand_total, :order_date, presence: true
end
