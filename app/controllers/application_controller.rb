# The basic class for all applications
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # rubocop:disable Style/GlobalVars
  def require_admin_http_auth!
    authenticate_or_request_with_http_basic('Administration') do |name, password|
      name == $auth_name && password == $auth_password
    end
  end
  # rubocop:enable Style/GlobalVars
end
