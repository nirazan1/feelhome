class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :prepare_exception_notifier
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  private
  def prepare_exception_notifier
    request.env["exception_notifier.exception_data"] = {
      :current_user => current_user
    }
  end

end
