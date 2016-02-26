# The basic class for all applications
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # rubocop:disable Style/GlobalVars
  def require_admin_http_auth!
    return if Rails.env.development? || Rails.env.test?
    authenticate_with_http_basic do |name, password|
      name == $auth_name && password == $auth_password
    end
  end
  # rubocop:enable Style/GlobalVars
end
