# A record to represent a survey. This is not an ActiveRecord-based model, just
# a place to centralize the survey-loading, processing in an object.
class Survey
  def initialize(name: 'form')
    hash = YAML::load(File.open(Rails.root.join('config', "#{name}.yml")))
    @hash = IceNine.deep_freeze(hash)
  end

  def questions
    @hash['questions']
  end
end
