class User < ApplicationRecord
  has_one :address
  has_many :orders
  has_many :reviews

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
end
