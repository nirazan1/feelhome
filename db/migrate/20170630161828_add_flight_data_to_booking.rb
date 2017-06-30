class AddFlightDataToBooking < ActiveRecord::Migration[5.0]
  def change
    add_column :bookings, :flight_data, :json
  end
end
