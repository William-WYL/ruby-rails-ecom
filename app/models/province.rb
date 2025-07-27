class Province < ApplicationRecord
  has_many :addresses
  has_many :orders

  validates :name, :code, presence: true
  validates :code, uniqueness: true
end
