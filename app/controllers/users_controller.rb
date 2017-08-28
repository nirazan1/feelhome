class UsersController < ApplicationController
  load_and_authorize_resource

  def show
    @user = User.find(params[:id])
  end

  def list
    @users = User.where.not(customer: nil)
  end

  def check_email
    user = User.find_by(email: params[:email]&.downcase)
    if user.nil?
      render json: {}, status: 200
    else
      render json: {}, status: 422
    end
  end

end
