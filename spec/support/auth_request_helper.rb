module AuthRequestHelper
  def auth_login
    http_login(admin_auth_name, admin_auth_password)
  end

  def http_login(user, password)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
  end
end
