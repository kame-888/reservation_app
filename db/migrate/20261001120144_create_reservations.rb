class CreateReservations < ActiveRecord::Migration[7.2]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.date :checkin_at
      t.date :checkout_at
      t.integer :guest_count

      t.timestamps
    end
  end
end
