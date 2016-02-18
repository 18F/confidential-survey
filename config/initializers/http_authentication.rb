# rubocop:disable Style/GlobalVars
unless Rails.env.development? || Rails.env.test?
  $auth_name = ENV['HTTP_AUTH_NAME']
  $auth_password = ENV['HTTP_AUTH_PASSWORD']

  if $auth_name.blank? || $auth_password.blank?
    fail 'You must provide an HTTP_AUTH_NAME and HTTP_AUTH_PASSWORD environment variables'
  end
end
# rubocop:enable Style/GlobalVars
