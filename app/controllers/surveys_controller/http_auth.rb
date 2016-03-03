class SurveysController
  class HttpAuth
    def initialize(controller, access_params)
      @controller = controller
      @user = access_params['user']
      @password = access_params['password']

      fail AccessException,
           'You must provide a user and password in the security config for http_auth' if
        @user.blank? || @password.blank?
    end

    def allowed?(_)
      authenticated = @controller.authenticate_or_request_with_http_basic('Administration') do |user, password|
        @user == user && @password == password
      end

      authenticated == true
    end

    def revoke_for_user(_)
      # does nothing
    end

    def hidden_form_variables(_)
      {}
    end
  end
end
