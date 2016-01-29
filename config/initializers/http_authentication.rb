unless Rails.env.development? || Rails.env.test?
  $auth_name = ENV['HTTP_AUTH_NAME']
  $auth_password = ENV['HTTP_AUTH_PASSWORD']

  fail "You must provide an HTTP_AUTH_NAME and HTTP_AUTH_PASSWORD environment variables" if $auth_name.blank? || $auth_password.blank?
end
