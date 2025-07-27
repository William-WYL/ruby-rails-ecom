class UpgradeToEcommerceSchema < ActiveRecord::Migration[7.0]
  def change
    # ==================================================
    # STEP 1: CREATE NEW TABLES
    # ==================================================

    # Create provinces table to store Canadian provinces and tax rates
    create_table :provinces do |t|
      t.string :name, null: false                    # Province full name
      t.string :code, null: false                    # Province code (e.g., AB, BC, MB)
      t.decimal :gst, precision: 5, scale: 3, default: 0.0  # GST tax rate
      t.decimal :pst, precision: 5, scale: 3, default: 0.0  # PST tax rate
      t.decimal :hst, precision: 5, scale: 3, default: 0.0  # HST tax rate
      t.timestamps
    end
    add_index :provinces, :code, unique: true       # Unique index on province code

    # Create addresses table to store user addresses with reference to provinces
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true        # Reference to user
      t.references :province, null: false, foreign_key: true    # Reference to province
      t.string :street, null: false                              # Street address
      t.string :city, null: false                                # City name
      t.string :postal_code, null: false                         # Postal code
      t.timestamps
    end

    # Create payments table to store order payment information
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true       # Reference to order
      t.string :processor, null: false                           # Payment processor (stripe, paypal, etc.)
      t.string :processor_id, null: false                        # Processor's transaction ID
      t.string :status, null: false                              # Payment status (pending, paid, failed)
      t.decimal :amount, precision: 10, scale: 2, null: false   # Payment amount
      t.timestamps
    end

    # Create order_statuses table to track the status history of orders
    create_table :order_statuses do |t|
      t.references :order, null: false, foreign_key: true       # Reference to order
      t.string :status, null: false                              # Status label (new, paid, shipped, etc.)
      t.timestamps
    end

    # Create pages table for static/editable pages like About, Contact, etc.
    create_table :pages do |t|
      t.string :slug, null: false                                # Unique page identifier (e.g., about, contact)
      t.string :title, null: false                               # Page title
      t.text :content, null: false                               # Page content
      t.timestamps
    end
    add_index :pages, :slug, unique: true                       # Unique index on slug

    # ==================================================
    # STEP 2: MODIFY EXISTING TABLES
    # ==================================================

    # Add price and tax-related columns to order_items table
    add_column :order_items, :unit_price, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :order_items, :applied_gst, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :order_items, :applied_pst, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :order_items, :applied_hst, :decimal, precision: 10, scale: 2, default: 0.0

    # Add references and tax totals to orders table
    add_reference :orders, :address, foreign_key: true
    add_reference :orders, :province, foreign_key: true
    add_column :orders, :subtotal, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :orders, :total_tax, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :orders, :grand_total, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :orders, :order_date, :datetime

    # ==================================================
    # STEP 3: MIGRATE EXISTING DATA USING RAW SQL
    # ==================================================
    reversible do |dir|
      dir.up do
        # Insert Canadian provinces with tax rates
        execute <<-SQL
          INSERT INTO provinces (name, code, gst, pst, hst, created_at, updated_at)
          VALUES
            ('Alberta', 'AB', 0.05, 0.0, 0.0, NOW(), NOW()),
            ('British Columbia', 'BC', 0.05, 0.07, 0.0, NOW(), NOW()),
            ('Manitoba', 'MB', 0.05, 0.07, 0.0, NOW(), NOW()),
            ('New Brunswick', 'NB', 0.0, 0.0, 0.15, NOW(), NOW()),
            ('Newfoundland and Labrador', 'NL', 0.0, 0.0, 0.15, NOW(), NOW()),
            ('Northwest Territories', 'NT', 0.05, 0.0, 0.0, NOW(), NOW()),
            ('Nova Scotia', 'NS', 0.0, 0.0, 0.15, NOW(), NOW()),
            ('Nunavut', 'NU', 0.05, 0.0, 0.0, NOW(), NOW()),
            ('Ontario', 'ON', 0.0, 0.0, 0.13, NOW(), NOW()),
            ('Prince Edward Island', 'PE', 0.0, 0.0, 0.15, NOW(), NOW()),
            ('Quebec', 'QC', 0.05, 0.09975, 0.0, NOW(), NOW()),
            ('Saskatchewan', 'SK', 0.05, 0.06, 0.0, NOW(), NOW()),
            ('Yukon', 'YT', 0.05, 0.0, 0.0, NOW(), NOW());
        SQL

        # Retrieve default province ID (Manitoba)
        default_province_id_result = execute("SELECT id FROM provinces WHERE code = 'MB' LIMIT 1")
        default_province_id = default_province_id_result.first&.[]("id") if default_province_id_result.any?

        # Create default addresses for all users with Manitoba as default province
        execute("SELECT id FROM users").each do |user|
          user_id = user["id"]
          execute(<<-SQL)
            INSERT INTO addresses (user_id, province_id, street, city, postal_code, created_at, updated_at)
            VALUES (
              #{user_id},
              #{default_province_id || 1},
              '123 Default St',
              'Winnipeg',
              'R3T 2N2',
              NOW(),
              NOW()
            )
          SQL
        end

        # Update orders with address and province information, update order_items prices and taxes
        execute("SELECT id FROM orders").each do |order|
          order_id = order["id"]

          # Fetch associated address and province for the order
          address_result = execute(<<-SQL)
            SELECT a.id AS address_id, p.id AS province_id
            FROM orders o
            JOIN users u ON u.id = o.user_id
            JOIN addresses a ON a.user_id = u.id
            JOIN provinces p ON p.id = a.province_id
            WHERE o.id = #{order_id}
            LIMIT 1
          SQL

          if address_result.any?
            address_id = address_result.first["address_id"]
            province_id = address_result.first["province_id"]

            # Update orders with address and province ids
            execute(<<-SQL)
              UPDATE orders
              SET address_id = #{address_id},
                  province_id = #{province_id}
              WHERE id = #{order_id}
            SQL
          end

          # Update order_items with current product prices
          execute(<<-SQL)
            UPDATE order_items
            SET unit_price = (
              SELECT price FROM products WHERE id = order_items.product_id
            )
            WHERE order_id = #{order_id}
          SQL

          # Apply GST and PST tax calculations (simplified example)
          execute(<<-SQL)
            UPDATE order_items
            SET applied_gst = unit_price * 0.05,
                applied_pst = unit_price * 0.07,
                applied_hst = 0
            WHERE order_id = #{order_id}
          SQL

          # Calculate and update order subtotal, total tax, and grand total
          execute(<<-SQL)
            UPDATE orders
            SET
              subtotal = (
                SELECT SUM(unit_price * quantity)
                FROM order_items
                WHERE order_id = #{order_id}
              ),
              total_tax = (
                SELECT SUM((applied_gst + applied_pst + applied_hst) * quantity)
                FROM order_items
                WHERE order_id = #{order_id}
              ),
              grand_total = subtotal + total_tax,
              order_date = created_at
            WHERE id = #{order_id}
          SQL
        end

        # Migrate payment data from orders table to payments table
        execute("SELECT id, status, total, created_at, updated_at FROM orders").each do |order|
          execute(<<-SQL)
            INSERT INTO payments (order_id, processor, processor_id, status, amount, created_at, updated_at)
            VALUES (
              #{order["id"]},
              'stripe',
              'pmt_#{order["id"]}_#{SecureRandom.hex(4)}',
              '#{order["status"] || "paid"}',
              #{order["total"] || 0},
              '#{order["created_at"]}',
              '#{order["updated_at"]}'
            )
          SQL

          execute(<<-SQL)
            INSERT INTO order_statuses (order_id, status, created_at, updated_at)
            VALUES (
              #{order["id"]},
              '#{order["status"] || "completed"}',
              '#{order["created_at"]}',
              '#{order["updated_at"]}'
            )
          SQL
        end

        # Create default static pages such as About Us and Contact Us
        execute(<<-SQL)
          INSERT INTO pages (slug, title, content, created_at, updated_at)
          VALUES
            ('about', 'About Us', 'This is the about page content. Edit me in the admin panel.', NOW(), NOW()),
            ('contact', 'Contact Us', 'This is the contact page content. Edit me in the admin panel.', NOW(), NOW())
        SQL
      end
    end
  end
end
