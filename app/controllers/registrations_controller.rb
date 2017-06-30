class RegistrationsController < Devise::RegistrationsController

  def create
    user = User.create(name: params[:user][:name], email: params[:user][:email],
                        contact_number: params[:user][:contact_number],
                        password: params[:user][:password]
                      )

    if user.save
      sign_in(:user, user)
      if params["flight_data"]
        flight_data = JSON.parse(params["flight_data"])
        booking = Booking.create(flight_data: flight_data, user: user, agent: User.default_agent)
        ApplicationMailer.quote_request(booking).deliver!
        redirect_to booking_path(booking), notice: "Account Created & Quote Request Received!"
      else
        redirect_to root_path
      end
    else
      redirect_to (:back), alert: user.errors.full_messages
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :contact_number, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:name, :contact_number, :email, :password, :password_confirmation, :current_password)
  end
end
