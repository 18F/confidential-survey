def admin_auth_name
  fail 'You must specify a SURVEY_ADMIN_USER' if ENV['SURVEY_ADMIN_USER'].blank?
  ENV['SURVEY_ADMIN_USER']
end

def admin_auth_password
  fail 'You must provide an SURVEY_ADMIN_PASSWORD' if ENV['SURVEY_ADMIN_PASSWORD'].blank?
  ENV['SURVEY_ADMIN_PASSWORD']
end

