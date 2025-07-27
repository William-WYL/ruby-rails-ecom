require "faker"
require "httparty"
require "csv"
require "open-uri"  # Required to open/download remote images

# Clear existing data in a proper order to avoid foreign key constraint errors
ProductTag.delete_all   # Join table between products and tags
Tag.delete_all          # Product tags
OrderItem.delete_all    # Items inside orders
Order.delete_all        # Customer orders
Review.delete_all       # Product reviews
Product.delete_all      # Products themselves (must delete before categories)
Category.delete_all     # Product categories (deleted last because products depend on them)
User.delete_all         # Users (usually can delete anytime, but here last)

# 1. Import categories from a CSV file
CSV.foreach(Rails.root.join("db", "categories.csv"), headers: true) do |row|
  Category.create!(name: row["name"])
end

# 2. Create tags for products (many-to-many relationship)
tag_names = ["New Arrival", "On Sale", "Limited Edition", "Best Seller"]
tags = tag_names.map { |name| Tag.create!(name: name) }

# 3. Fetch product data from FakeStore API and create products
response = HTTParty.get("https://fakestoreapi.com/products")
products_data = JSON.parse(response.body)

products_data.each do |product_data|
  # Find category by name or fallback to first category if none found
  category = Category.find_by(name: product_data["category"]) || Category.first

  # Create product record without image_url attribute, since images use ActiveStorage
  product = Product.create!(
    title: product_data["title"],
    price: product_data["price"],
    description: product_data["description"],
    category: category,
  )

  # Download and attach product image using ActiveStorage
  begin
    downloaded_image = URI.open(product_data["image"])
    filename = File.basename(URI.parse(product_data["image"]).path)
    product.image.attach(
      io: downloaded_image,
      filename: filename,
      content_type: downloaded_image.content_type,
    )
  rescue => e
    puts "❌ Failed to attach image for product '#{product.title}': #{e.message}"
  end

  # Assign 1 to 3 random tags to the product
  product.tags << tags.sample(rand(1..3))
end

# 4. Create sample users, their orders, order items, and product reviews
50.times do
  user = User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
  )

  # Create one order per user with random status and total price
  order = Order.create!(
    user: user,
    status: ["pending", "completed", "shipped"].sample,
    total: Faker::Commerce.price(range: 10..1000.0),
  )

  # Add 1 to 5 random products to the order with random quantities
  rand(1..5).times do
    OrderItem.create!(
      order: order,
      product: Product.all.sample,
      quantity: rand(1..5),
    )
  end

  # Each user leaves between 0 and 3 reviews for random products
  rand(0..3).times do
    Review.create!(
      product: Product.all.sample,
      user: user,
      rating: rand(1..5),
      comment: Faker::Lorem.paragraph,
    )
  end
end

puts "✅ Seeded #{User.count} users, #{Product.count} products, #{Order.count} orders, #{Tag.count} tags"
