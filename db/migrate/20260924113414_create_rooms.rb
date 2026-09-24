class CreateRooms < ActiveRecord::Migration[7.2]
  def change
    create_table :rooms do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description, null: false
      t.integer :price, null: false
      t.string :address, null: false
      t.binary :image

      t.timestamps
    end
  end
end
