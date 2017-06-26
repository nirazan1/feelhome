class BookingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @bookings = Booking.all
  end

  def edit
    @new_user = User.new
    @booking = Booking.find(params[:id])
  end

  def show
    @booking = Booking.find(params[:id])
  end

  def new
    @booking = Booking.new
    @new_user = User.new
  end

  def create
    @new_user = User.new(user_params)
    @booking = Booking.new(booking_params)
    if current_user.agent?
      @booking.update_attributes(agent: current_user)
    elsif current_user.customer?
      @booking.update_attributes(user: current_user, agent: User.default_agent)
    end

    if @booking.user.nil?
      @new_user.save(validate: false)
      @booking.update_attributes(user: @new_user)
    end

    if @booking.save
      redirect_to @booking
    else
      render 'new'
    end
  end

  def update
    @new_user = User.new(user_params)
    @booking = Booking.find(params[:id])

    if current_user.agent?
      @booking.update_attributes(agent: current_user)
    elsif current_user.customer?
      @booking.update_attributes(user: current_user, agent: User.default_agent)
    end

    if booking_params[:user_id].blank?
      @new_user.save(validate: false)
      updated_params = booking_params.merge!(user_id: "#{@new_user.id}")
    end

    if @booking.update(updated_params || booking_params)
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

  def user_params
    params.require(:user).permit(:name, :contact_number, :email)
  end

end
