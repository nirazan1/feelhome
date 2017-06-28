class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :prepare_exception_notifier

  private
  def prepare_exception_notifier
    request.env["exception_notifier.exception_data"] = {
      :current_user => current_user
    }
  end

end
