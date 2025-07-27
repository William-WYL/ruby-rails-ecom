class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items
  has_many :reviews
  has_one_attached :image
  has_many :product_tags, dependent: :destroy
  has_many :tags, through: :product_tags

  validates :title, :description, :price, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id title price description category_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[category image_attachment image_blob order_items product_tags reviews tags]
  end
end
