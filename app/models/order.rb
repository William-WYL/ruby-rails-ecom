class Order < ApplicationRecord
  belongs_to :user
  belongs_to :address
  belongs_to :province

  has_many :order_items
  has_one :payment
  has_one :order_status

  validates :subtotal, :total_tax, :grand_total, :order_date, presence: true

  # Define searchable associations for ActiveAdmin/Ransack
  def self.ransackable_associations(auth_object = nil)
    ["address", "order_items", "order_status", "payment", "province", "user"]
  end

  # Define searchable attributes for ActiveAdmin/Ransack
  def self.ransackable_attributes(auth_object = nil)
    ["id", "order_date", "status", "subtotal", "total_tax", "grand_total", "created_at", "updated_at"]
  end
end
