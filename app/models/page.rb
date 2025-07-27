# app/models/page.rb
class Page < ApplicationRecord
  validates :slug, presence: true, uniqueness: true
  validates :title, :content, presence: true

  def self.about
    find_by(slug: "about")
  end

  def self.contact
    find_by(slug: "contact")
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id slug title content created_at updated_at]
  end
end
