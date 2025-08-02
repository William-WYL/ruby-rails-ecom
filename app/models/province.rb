class Province < ApplicationRecord
  has_many :addresses
  has_many :orders

  validates :name, :code, presence: true
  validates :code, uniqueness: true

  def total_tax_rate
    gst + pst + hst
  end

  def tax_breakdown(subtotal)
    {
      gst: subtotal * gst,
      pst: subtotal * pst,
      hst: subtotal * hst,
      total: subtotal * total_tax_rate
    }
  end

  def gst
    read_attribute(:gst) || 0.0
  end

  def pst
    read_attribute(:pst) || 0.0
  end

  def hst
    read_attribute(:hst) || 0.0
  end
end
