# The only controller we need for handling the survey form for now
class SurveyController < ApplicationController
  before_filter :load_survey

  def new
  end

  def submit
    raise params.inspect
  end

  private

  def load_survey
    @survey = Survey.new
  end
end
