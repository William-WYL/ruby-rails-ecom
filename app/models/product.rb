class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items
  has_many :reviews
  has_one_attached :image
  has_many :product_tags
  has_many :tags, through: :product_tags

  validates :title, :description, :price, presence: true
end
