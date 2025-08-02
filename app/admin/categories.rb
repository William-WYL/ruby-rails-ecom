ActiveAdmin.register Category do
  permit_params :name

  index do
    selectable_column
    id_column
    column :name
    column :created_at

    column "Actions" do |category|
      span link_to "View", admin_category_path(category), class: "button"
      span " "
      span link_to "Edit", edit_admin_category_path(category), class: "button"
    end
  end

  filter :name
  filter :created_at

  form do |f|
    f.inputs "Category Details" do
      f.input :name
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :created_at
      row :updated_at
    end

    div class: "panel-footer" do
      form_tag admin_category_path(resource), method: :delete, data: { confirm: "Are you sure you want to delete this category?" } do
        submit_tag "Delete Category", class: "button"
      end
    end
  end
end
