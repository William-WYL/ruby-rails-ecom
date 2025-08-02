ActiveAdmin.register Product do
  actions :all
  permit_params :title, :description, :price, :category_id, :image, tag_ids: []

  index do
    selectable_column
    column "Image" do |product|
      if product.image.attached?
        image_tag url_for(product.image), size: "80x80"
      end
    end
    id_column
    column :title
    # column :description
    column :price
    column :category_id
    column :created_at
    column :updated_at
    column("Tags") { |product| product.tags.map(&:name).join(", ") }

    # Custom actions column without Delete button
    column "Actions" do |product|
      span link_to "View", admin_product_path(product), class: "button"
      span link_to "Edit", edit_admin_product_path(product), class: "button"
    end
  end

  filter :title
  filter :price
  filter :category

  show do
    attributes_table do
      row :id
      row :title
      row :price
      row :description
      row :category
      row :image do |product|
        if product.image.attached?
          image_tag url_for(product.image), style: "max-width: 200px;"
        else
          "No Image"
        end
      end
      row("Tags") { |product| product.tags.map(&:name).join(", ") }
      row :created_at
      row :updated_at
    end

    # Custom actions panel with Delete button
    panel "Actions" do
      div do
        form_tag admin_product_path(resource), method: :delete, data: { confirm: "Are you sure you want to delete this product?" } do
          submit_tag "Delete Product", class: "button"
        end
      end
    end
  end

  form do |f|
    f.inputs "Product Details" do
      f.input :title
      f.input :description
      f.input :price
      f.input :category
      f.input :image, as: :file, hint: f.object.image.attached? ? image_tag(f.object.image.variant(resize_to_limit: [100, 100])) : content_tag(:span, "No image yet")
      f.input :tags, as: :check_boxes, collection: Tag.all
    end
    f.actions
  end
end
