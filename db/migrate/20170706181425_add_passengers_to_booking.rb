class AddPassengersToBooking < ActiveRecord::Migration[5.0]
  def change
    add_column :bookings, :passengers, :string
    add_column :bookings, :trip_option, :string
  end
end
