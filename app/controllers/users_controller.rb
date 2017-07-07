class UsersController < ApplicationController
  load_and_authorize_resource

  def show
    @user = User.find(params[:id])
  end

  def list
    @users = User.where.not(customer: nil)
  end

end
