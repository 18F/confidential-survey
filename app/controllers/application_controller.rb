# The basic class for all applications
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def require_admin_auth!
    require_http_auth!(admin_auth_name, admin_auth_password)
  end

  def require_http_auth!(name, password)
    authenticated = authenticate_or_request_with_http_basic('Administration') do |provided_name, provided_password|
      name == provided_name && password == provided_password
    end

    authenticated == true
  end
end
