class CreateBookings < ActiveRecord::Migration[5.0]
  def change
    create_table :bookings do |t|
      t.text :notes
      t.string :airline
      t.string :origin
      t.string :destination
      t.string :flght_number
      t.datetime :flight_time
      t.string :pnr
      t.string :ticket_number
      t.datetime :ticket_time_limit
      t.integer :bill_number
      t.string :currency
      t.integer :amount
      t.integer :recipt_number
      t.string :ticket_type
      t.references :agent, index: true, foreign_key: { to_table: :users }
      t.references :user, index: true, foreign_key: { to_table: :users }
      t.timestamps
    end
  end

end
