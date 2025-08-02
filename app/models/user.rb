class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :address, dependent: :destroy
  has_many :orders
  has_many :reviews

  # Accept nested attributes for address
  accepts_nested_attributes_for :address, allow_destroy: true

  def admin?
    self.admin
  end

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  # Build address if it doesn't exist
  def build_address_if_needed
    build_address if address.nil?
  end
end
