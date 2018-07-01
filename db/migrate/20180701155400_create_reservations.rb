class CreateReservations < ActiveRecord::Migration[5.2]
  def change
    create_table :reservations do |t|
      t.string :name
      t.string :place
      t.string :room
      t.string :organization
      t.datetime :datetime
      t.time :finish_time
      t.integer :members
      t.string :division
      t.string :status
    end
  end
end
