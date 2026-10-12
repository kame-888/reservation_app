class RemoveConfirmedPasswordFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :confirmed_password, :string
  end
end
