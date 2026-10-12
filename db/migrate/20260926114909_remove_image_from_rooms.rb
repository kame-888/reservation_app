class RemoveImageFromRooms < ActiveRecord::Migration[7.2]
  def change
    remove_column :rooms, :image, :binary
  end
end
