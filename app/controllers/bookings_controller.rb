class BookingsController < ApplicationController
  def index
    @bookings = Booking.all
  end

  def edit
    @booking = Booking.find(params[:id])
  end

  def show
    @booking = Booking.find(params[:id])
  end

  def new
    @booking = Booking.new
  end

  def create
    @booking = Booking.new(booking_params)

    if @booking.save
      redirect_to @booking
    else
      render 'new'
    end
  end

  def update
    @booking = Booking.find(params[:id])

    if @booking.update(booking_params)
      redirect_to @booking
    else
      render 'edit'
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy

    redirect_to bookings_path
  end

  private
  def booking_params
    params.require(:booking).permit(:notes, :airline, :origin, :destination,
     :flight_time, :flght_number, :pnr, :ticket_number, :ticket_time_limit,
     :bill_number, :currency, :amount, :recipt_number, :ticket_type, :agent_id, :user_id)
  end

end
