ActiveAdmin.register Page do
  permit_params :slug, :title, :content

  index do
    selectable_column
    id_column
    column :slug
    column :title
    column :created_at
    column :updated_at

    column "Actions" do |page|
      span link_to "View", admin_page_path(page)
      span " " # Spacer
      span link_to "Edit", edit_admin_page_path(page)
    end
  end

  filter :slug
  filter :title
  filter :created_at

  form do |f|
    f.inputs "Page Details" do
      f.input :slug, hint: "Unique identifier, e.g. 'about', 'contact'"
      f.input :title
      f.input :content, as: :text, input_html: { rows: 10 }
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :slug
      row :title
      row :content do |page|
        raw page.content
      end
      row :created_at
      row :updated_at
    end

    div class: "panel-footer" do
      form_tag admin_page_path(resource), method: :delete, data: { confirm: "Are you sure you want to delete this page?" } do
        submit_tag "Delete Page", class: "delete-button"
      end
    end
  end
end
