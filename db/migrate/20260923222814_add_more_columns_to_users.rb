class AddMoreColumnsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :confirmed_password, :string
    add_column :users, :introduction, :text
    add_column :users, :image, :string
  end
end
