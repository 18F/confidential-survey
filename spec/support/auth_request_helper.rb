module AuthRequestHelper
  def auth_login
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(admin_auth_name, admin_auth_password)
  end
end
