# app/admin/pages.rb
ActiveAdmin.register Page do
  # Allow these fields to be edited in forms
  permit_params :slug, :title, :content

  # Index table configuration
  index do
    selectable_column
    id_column
    column :slug
    column :title
    column :created_at
    column :updated_at

    # Custom actions column (replaces default 'actions')
    column "Actions" do |page|
      # Use span for inline styling (you can add CSS classes if needed)
      span link_to "View", admin_page_path(page)
      span " " # Spacer
      span link_to "Edit", edit_admin_page_path(page)
      span " " # Spacer
      # Direct DELETE link with browser confirmation
      span link_to "Delete", admin_page_path(page),
                   method: :delete,
                   data: { confirm: "Are you sure you want to delete this page?" }
    end
  end

  # Filters for the index page
  filter :slug
  filter :title
  filter :created_at

  # Form configuration
  form do |f|
    f.inputs "Page Details" do
      f.input :slug, hint: "Unique identifier, e.g. 'about', 'contact'"
      f.input :title
      f.input :content, as: :text, input_html: { rows: 10 }
    end
    f.actions
  end

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :slug
      row :title
      row :content do |page|
        raw page.content # Allows HTML rendering
      end
      row :created_at
      row :updated_at
    end

    # Add custom delete button to show page
    div class: "panel-footer" do
      # Direct DELETE link with browser confirmation
      link_to "Delete Page", admin_page_path(resource),
              method: :delete,
              class: "delete-button",
              data: { confirm: "Are you sure you want to delete this page?" }
    end
  end
end
