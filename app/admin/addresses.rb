ActiveAdmin.register Address do
  permit_params :street, :city, :postal_code, :province_id, :user_id

  index do
    selectable_column
    id_column
    column :user do |address|
      link_to address.user.name, admin_user_path(address.user) if address.user
    end
    column :street
    column :city
    column :postal_code
    column :province do |address|
      address.province.name if address.province
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :user do |address|
        link_to address.user.name, admin_user_path(address.user) if address.user
      end
      row :street
      row :city
      row :postal_code
      row :province do |address|
        address.province.name if address.province
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Address Details" do
      f.input :user, as: :select, collection: User.all.collect { |u| [u.name, u.id] }
      f.input :street
      f.input :city
      f.input :postal_code
      f.input :province, as: :select, collection: Province.all.collect { |p| [p.name, p.id] }
    end
    f.actions
  end

  filter :user, as: :select, collection: -> { User.all.collect { |u| [u.name, u.id] } }
  filter :street
  filter :city
  filter :postal_code
  filter :province, as: :select, collection: -> { Province.all.collect { |p| [p.name, p.id] } }
  filter :created_at
end
