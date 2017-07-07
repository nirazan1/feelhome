class ApplicationMailer < ActionMailer::Base
  default from: 'admin@feelhometravels.com'

  def agent_reminder(booking)
    @booking = booking
    @agent = booking.agent
    mail(:to => @agent.email, :subject => "FeelHomeTravels :: Expiring Booking Reminder !")
  end

  def customer_reminder(booking)
    @booking = booking
    @customer = booking.user
    mail(:to => @customer.email, :subject => "FeelHomeTravels :: Expiring Booking Reminder !") if @customer&.email
  end

  def quote_request(booking)
    @agent = User.first
    @booking = booking
    @customer = booking.user
    mail(:to => @agent.email, :subject => "FeelHomeTravels :: New Quote Requested! ")
  end

  def customer_init_booking(booking, new_booking)
    @agent = User.first
    @booking = booking
    @customer = booking.user
    @new_booking = new_booking
    mail(:to => @agent.email, :subject => "FeelHomeTravels :: #{ new_booking ? 'Customer Created A New Booking': 'Customer Updated A Booking' }")
  end

  def new_account_creation(booking, generated_password)
    @booking = booking
    @customer = @booking.user
    @password = generated_password
    mail(:to => @customer.email, :subject => "FeelHomeTravels :: Account Created ! ")
  end

  def booking_updated(booking, user)
    @booking = booking
    @user = user
    mail(:to => User.default_agent.email, :subject => "FeelHomeTravels :: Booking Updated ! ")
  end

end
