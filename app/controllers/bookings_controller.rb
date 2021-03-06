class BookingsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:search, :set_flight]
  load_and_authorize_resource except: [:search, :set_flight, :create]
  before_action :check_user_email, only: [:create, :update]

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
    if params["flight_data"]
      flight_data = JSON.parse(params["flight_data"])
      @booking = Booking.create(flight_data: flight_data, user: current_user, agent: User.default_agent)
      ApplicationMailer.quote_request(@booking).deliver!
    else
      @booking = Booking.new(booking_params)
      if current_user.agent?
        @booking.update_attributes(agent: current_user)
      elsif current_user.customer?
        @booking.update_attributes(user: current_user, agent: User.default_agent)
      end
    end

    if @booking.user.nil?
      generated_password = Devise.friendly_token.first(8)
      @new_user.update_attributes(password: generated_password)
      @new_user.save(validate: false)
      @booking.update_attributes(user: @new_user)
      ApplicationMailer.new_account_creation(@booking, generated_password).deliver! if @new_user.email.present? && params["flight_data"].nil?
    end

    if @booking.save
      ApplicationMailer.customer_init_booking(@booking, new_booking = true).deliver! if current_user.customer?
      redirect_to @booking, notice: 'Booking Created !'
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
    @booking = Booking.new
    if Rails.env.development?
      response = Qpx.sample_response.with_indifferent_access
      @trip_data = response["trips"]["data"]
      @trip_option = response["trips"]["tripOption"]
      redirect_to new_user_session_path, alert: 'no data found !' if response.blank?
    else
      response = HTTParty.post("https://www.googleapis.com/qpxExpress/v1/trips/search?key=AIzaSyBjVK8xezhFNYx-aJSRJiPIJi8ecMqNKpY",
        {
          :body => search_body.to_json,
          :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
        })
      if response&.success?
        response = response.with_indifferent_access
        @trip_data = response["trips"]["data"]
        @trip_option = response["trips"]["tripOption"]
        redirect_to new_user_session_path, alert: 'no data found !' if response.blank?
      else
        redirect_to new_user_session_path, alert: @response&.dig(:error) || '404: search data not found !'
      end
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

  def check_user_email
    return if params[:flight_data].present?
    if params[:flight_data].nil? && booking_params[:user_id].blank? && user_params[:email].blank?
      redirect_to (:back), alert: "User Email Cannot Be Blank ! If you dont have user's email use <user name>@mailinator.com. e.g. actionaid@mailinator.com"
    elsif booking_params[:user_id].blank? && User.find_by(email: user_params[:email])
      redirect_to (:back), alert: "User with email #{user_params[:email]} already exists ! If you dont have user's email use #{user_params[:contact_number]}@mailinator.com"
    end
  end

  private
  def booking_params
    if params[:booking].present?
      params.require(:booking).permit(:notes, :airline, :origin, :destination,
     :flight_time, :flght_number, :pnr, :ticket_number, :ticket_time_limit,
     :bill_number, :currency, :amount, :recipt_number, :ticket_type, :agent_id, :user_id, :trip_option, :passengers)
    end
  end

  def user_params
    params.require(:user).permit(:name, :contact_number, :email)
  end

end
