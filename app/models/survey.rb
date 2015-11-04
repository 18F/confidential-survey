# A record to represent a survey. This is not an ActiveRecord-based model, just
# a place to centralize the survey-loading, processing in an object.
class Survey
  include ActiveModel::Conversion

  # Needed to make Rails forms happy
  def model_name
    ActiveModel::Name.new(Survey)
  end

  def persisted?
    false
  end

  def initialize(arg)
    hash = case arg
           when String
             YAML.load(File.open(Rails.root.join('config', 'surveys', "#{arg}.yml")))
               .merge({'id': arg}) 
           when Hash
             arg
           else
             fail 'Not implemented yet'
           end
    
    @hash = IceNine.deep_freeze(hash)

    validate_survey
  end

  def survey_id
    @hash[:id]
  end
  alias_method :id, :survey_id

  def questions
    if @questions.nil?
      @questions = @hash['questions'].map { |h| Question.new(survey_id, h) }
    end

    @questions
  end

  def record(responses)
    responses.each do |key, answers|
      q = questions.detect { |q| q.key == key }
      fail "Question #{key} not found" if q.nil?
      
      q.record(answers)
    end
  end

  def tally_for(field, value)
    Tally.tally_for(survey_id, field, value)
  end
  
  private

  def validate_survey
    fail 'You must include an id field in the survey' if survey_id.blank?
  end
  
  def method_missing(method_sym, *arguments, &block)
    if @hash['questions'].any? {|h| h['key'] == method_sym.to_s }
      nil
    else
      super
    end
  end
end
