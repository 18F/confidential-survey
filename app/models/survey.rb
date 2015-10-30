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

  def initialize(arg)
    hash = case arg
           when String
             YAML.load(File.open(Rails.root.join('config', "#{arg}.yml")))
           when Hash
             arg
           else
             fail 'Not implemented yet'
           end
      
    @hash = IceNine.deep_freeze(hash)
  end

  def questions
    if @questions.nil?
      @questions = @hash['questions'].map {|h| Question.new(h)}
    end

    @questions
  end

  def record(responses)
    responses.each do |key, answers|
      q = questions.detect {|q| q.key == key}
      raise "Question #{key} not found" if q.nil?
      
      q.record(answers)
    end
  end

  def method_missing(method_sym, *arguments, &block)
    if @hash['questions'].any? {|h| h['key'] == method_sym.to_s }
      nil
    else
      super
    end
  end
end
