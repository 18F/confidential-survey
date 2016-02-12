# The only controller we need for handling the survey form for now
class SurveysController < ApplicationController
  before_action :load_survey, only: [:submit, :show, :results]

  def show
    respond_to do |format|
      format.html { @md = Redcarpet::Markdown.new(Redcarpet::Render::HTML) }
      format.json { render json: Serializers::Survey.new(@survey).as_json }
    end
  end

  def submit
    fail 'Survey ID does not match' unless params[:survey][:id] == @survey.id

    ResponseProcessor.new(params[:survey], @survey).perform
    redirect_to(action: :thanks)
  end

  def thanks
  end

  private

  def load_survey
    @survey = Survey.new(params[:id])
    fail ActiveRecord::RecordNotFound unless @survey.active?

  rescue ActiveRecord::RecordNotFound
    render status: 404
  end
end
