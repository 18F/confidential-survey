# The only controller we need for handling the survey form for now
class SurveysController < ApplicationController
  before_filter :load_survey

  def new
  end

  def create
    raise params.inspect
  end

  private

  def load_survey
    @survey = Survey.new
  end
end
