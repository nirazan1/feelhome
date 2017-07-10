class BookingsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:search, :set_flight]
  load_and_authorize_resource except: [:search, :set_flight, :create]

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
                    Booking.pending
                  elsif params[:tab] == 'all_completed_bookings'
                    Booking.completed
                  elsif params[:tab] == 'all_bookings'
                    Booking.all
                  elsif params[:tab] == 'payment_due'
                    Booking.payment_due
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
    @new_user = User.new(user_params) if params[:user]
    @booking = Booking.new(booking_params)
    if current_user.agent?
      @booking.update_attributes(agent: current_user)
    elsif current_user.customer?
      @booking.update_attributes(user: current_user, agent: User.default_agent)
    end

    if @booking.user.nil?
      generated_password = Devise.friendly_token.first(8)
      @new_user.update_attributes(password: generated_password)
      @new_user.save(validate: false)
      @booking.update_attributes(user: @new_user)
      ApplicationMailer.new_account_creation(@booking, generated_password).deliver! if @new_user.email.present?
    end

    if @booking.save
      ApplicationMailer.customer_init_booking(@booking, new_booking = true).deliver! if current_user.customer?
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
      ApplicationMailer.customer_init_booking(@booking, new_booking = false).deliver! if current_user.customer?
      ApplicationMailer.booking_updated(@booking, current_user).deliver!
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

  def set_flight
    session[:flight_number] = params[:flight_number].to_i
    render json: {}
  end

  def search
    @user = User.new
    @response = HTTParty.post("https://www.googleapis.com/qpxExpress/v1/trips/search?key=AIzaSyBjVK8xezhFNYx-aJSRJiPIJi8ecMqNKpY",
      {
        :body => search_body.to_json,
        :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
      }) if Rails.env.production?
    if @response&.success?
      @response = @response["trips"]["tripOption"]
    else
      redirect_to new_user_session_path, alert: @response&["error"] || '404 not found !'
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
     :bill_number, :currency, :amount, :recipt_number, :ticket_type, :agent_id, :user_id, :trip_option, :passengers)
  end

  def user_params
    params.require(:user).permit(:name, :contact_number, :email)
  end

end
