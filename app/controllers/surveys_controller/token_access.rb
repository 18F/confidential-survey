class SurveysController
  class TokenAccess
    def initialize(survey_id)
      @survey_id = survey_id
    end

    def allowed?(params)
      @token = params[:token]
      SurveyToken.valid?(@survey_id, params[:token])
    end

    def revoke_for_user(params)
      SurveyToken.revoke(@survey_id, params[:token])
    end

    def hidden_form_variables(params)
      {token: params[:token]}
    end
  end
end
