# app/models/payment.rb
class Payment < ApplicationRecord
  belongs_to :order

  STATUSES = %w[pending paid failed refunded].freeze
  validates :status, inclusion: { in: STATUSES }

  def successful?
    status == "paid"
  end
end
