class BookingsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: :search

  def index
    @bookings = if current_user.customer?
                  if params[:tab] == 'completed_bookings'
                    current_user.user_bookings.completed
                  elsif params[:tab] == 'all_bookings'
                    current_user.user_bookings
                  else
                    current_user.user_bookings.pending
                  end
                elsif current_user.agent?
                  if params[:tab] == 'completed_bookings'
                    current_user.agent_bookings.completed
                  elsif params[:tab] == 'all_pending_bookings'
                    Booking.all.pending
                  elsif params[:tab] == 'all_completed_bookings'
                    Booking.all.completed
                  elsif params[:tab] == 'all_bookings'
                    Booking.all
                  else
                    current_user.agent_bookings.pending
                  end
                else
                  Booking.all
                end
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

  def search
    @response = HTTParty.post("https://www.googleapis.com/qpxExpress/v1/trips/search?key=AIzaSyBjVK8xezhFNYx-aJSRJiPIJi8ecMqNKpY",
      {
        :body => search_body.to_json,
        :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
      })
    if @response.success?
      @response = @response["trips"]["tripOption"]
    else
      redirect_to new_user_session_path, alert: @response["error"]
      # render :json => { :errors => @response["error"] }
    end
  end


  def quote_request

  end

  def search_body
    tck_class = params["trip_class"] == "1" ? "BUSINESS" : ""
    body =  {
              "request": {
                "slice": [
                  {
                    "origin": params["origin_iata"],
                    "destination": params["destination_iata"],
                    "date": params["depart_date"],
                    "preferredCabin": tck_class
                  }
                ],
                "passengers": {
                  "adultCount": params["adults"],
                  "infantInSeatCount": params["infants"],
                  "childCount": params["children"],
                  "seniorCount": 0
                },
                "solutions": 10
              }
            }
    body[:request][:slice] << {
              "origin": params["destination_iata"],
              "destination": params["origin_iata"],
              "date": params["return_date"],
              "preferredCabin": tck_class
            } if params[:return_date].present?
    body
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
