# A record to represent a survey. This is not an ActiveRecord-based model, just
# a place to centralize the survey-loading, processing in an object.
class Survey
  include ActiveModel::Conversion
  
  def model_name
    ActiveModel::Name.new(Survey)
  end

  def persisted?
    false
  end

  def initialize(name: 'form')
    hash = YAML::load(File.open(Rails.root.join('config', "#{name}.yml")))
    @hash = IceNine.deep_freeze(hash)
  end

  def questions
    @hash['questions'].map {|h| Question.new(h)}
  end

  def record(responses)
  end

  def method_missing(method_sym, *arguments, &block)
    if @hash['questions'].any? {|h| h['key'] == method_sym.to_s }
      nil
    else
      super
    end
  end
end
