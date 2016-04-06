# The only controller we need for handling the survey form for now
class SurveysController < ApplicationController
  before_action :load_survey, only: [:submit, :show, :results, :generate_token, :revoke_tokens]

  def show
    check_access_allowed!
    @hidden = access_control.hidden_form_variables(params)
    @md = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  end

  def survey_json
    @survey = Survey.new(params[:id])
    render json: Serializers::Survey.new(@survey).as_json
  end

  def submit
    check_access_allowed!
    ResponseProcessor.new(params[:survey], @survey).perform
    revoke_access!
    redirect_to(action: :thanks)
  end

  def generate_token
    require_admin_auth!
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
    require_admin_auth!
    @survey.revoke_all_tokens
    render text: 'All tokens revoked', status: :ok
  end

  def thanks
  end

  private

  rescue_from ActionController::RoutingError, with: -> { render_404 }
  rescue_from ActiveRecord::RecordNotFound, with: -> { render_404 }
  rescue_from AccessException, with: -> { render_404 }

  def render_404
    return if status == 401 # for HTTP auth support
    respond_to do |format|
      format.html { render text: 'not found', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def load_survey
    @survey = Survey.new(params[:id])
    fail ActiveRecord::RecordNotFound unless @survey.active?
  end

  def access_params
    @access_params ||= @survey.access_params
  end

  def access_control
    if @access_control.nil?
      @access_control = case access_params['type']
                        when 'token'
                          TokenAccess.new(@survey.survey_id)
                        when 'http_auth'
                          HttpAuth.new(self, access_params)
                        else
                          fail AccessException, "Unrecognized access control type: #{access_params['type']}"
                        end
    end

    @access_control
  end

  def check_access_allowed!
    fail AccessException unless access_control.allowed?(params)
  end

  def revoke_access!
    access_control.revoke_for_user(params)
  end
end
