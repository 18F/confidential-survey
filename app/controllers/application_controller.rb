# The basic class for all applications
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # rubocop:disable Style/GlobalVars
  unless Rails.env.development? || Rails.env.test?
    http_basic_authenticate_with name: $auth_name, password: $auth_password
  end
  # rubocop:enable Style/GlobalVars
end
