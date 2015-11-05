# The only controller we need for handling the survey form for now
class SurveysController < ApplicationController
  before_filter :load_survey, only: [:submit, :show, :results]

  def show
  end

  def submit
    if params[:survey][:id] != @survey.id
      fail 'Survey ID does not match'
    end
    
    @survey.record(params[:survey])
    redirect_to(action: :thanks)
  end

  def thanks
  end
  
  private

  def load_survey
    @survey = Survey.new(params[:id])
  end
end
