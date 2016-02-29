# The only controller we need for handling the survey form for now
class SurveysController < ApplicationController
  before_action :load_survey, only: [:submit, :show, :results, :generate_token, :revoke_tokens]

  http_basic_authenticate_with name: admin_auth_name,
                               password: admin_auth_password,
                               only: [:generate_token, :revoke_tokens]
  
  def show
    respond_to do |format|
      format.html do
        validate_survey_token!
        @md = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      end
      
      format.json do
        render json: Serializers::Survey.new(@survey).as_json
      end                                                             
    end
  end

  def submit
    validate_survey_token!
    ResponseProcessor.new(params[:survey], @survey).perform
    revoke_survey_token!
    redirect_to(action: :thanks)
  end

  def generate_token
    out = ''
    
    n = 1
    n = params[:n].to_i if params[:n]

    n.times.each do
      token = SurveyToken.generate(@survey.survey_id)
      out << survey_url(@survey.survey_id) + '?token=' + token + "\n"
    end
    
    render text: out, status: :ok
  end

  def revoke_tokens
    @survey.revoke_all_tokens
    render text: 'All tokens revoked', status: :ok
  end
  
  def thanks
  end

  private

  rescue_from ActionController::RoutingError, with: -> { render_404  }
  rescue_from ActiveRecord::RecordNotFound, with: -> { render_404 }

  def render_404
    respond_to do |format|
      format.html { render text: 'not found', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end
  
  def load_survey
    @survey = Survey.new(params[:id])
    fail ActiveRecord::RecordNotFound unless @survey.active?
  end

  def validate_survey_token!
    @token = params[:token]
    fail ActiveRecord::RecordNotFound unless @survey.valid_token?(@token)
  end

  def revoke_survey_token!
    @survey.revoke_token(@token)
  end
end
