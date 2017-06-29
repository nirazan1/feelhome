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

end
