# A record to represent a survey. This is not an ActiveRecord-based model, just
# a place to centralize the survey-loading, processing in an object.
class Survey
  include ActiveModel::Conversion

  SURVEY_META_KEY = '_survey'.freeze
  SURVEY_PARTICIPANTS = 'participants'.freeze

  # Needed to make Rails forms happy
  def model_name
    ActiveModel::Name.new(Survey)
  end

  def persisted?
    false
  end

  def initialize(arg)
    raise ActiveRecord::NotFound if arg.nil?
    
    hash = case arg
           when String
             YAML.load(File.open(Rails.root.join('config', 'surveys', "#{arg}.yml"))).merge('id' => arg)
           when Hash
             arg
           else
             fail 'Not implemented yet'
           end

    @hash = IceNine.deep_freeze(hash)

    validate_survey
  rescue Errno::ENOENT
    raise ActiveRecord::RecordNotFound, "Survey #{arg} not found"
  end

  def intro
    if @intro.nil?
      @intro = @hash['intro']

      # load a markdown file if specified
      if @intro =~ /\.md$/
        @intro = File.read(Rails.root.join('config', 'surveys', @intro))
      end
    end

    @intro
  end

  def title
    @hash['title']
  end

  def description
    @hash['description']
  end

  def active?
    !(@hash.key?('active') && @hash['active'] == false)
  end

  def valid_token?(token)
    SurveyToken.valid?(survey_id, token)
  end

  def revoke_token(token)
    SurveyToken.revoke(survey_id, token)
  end

  def revoke_all_tokens
    SurveyToken.revoke_all_for_survey(survey_id)
  end
  
  def survey_id
    @hash['id']
  end
  alias id survey_id

  def questions
    if @questions.nil?
      @questions = @hash['questions'].map {|h| Question.new(self, h) }
    end

    @questions
  end

  def valid_question_key?(key)
    questions.detect {|q| q.key == key } != nil
  end

  def [](key)
    questions.detect {|q| q.key == key }
  end

  def intersections
    if @intersections.nil?
      @intersections = @hash['intersections'].map {|h| Intersection.new(self, h) }
    end

    @intersections
  end

  def tally_for(field, value)
    Tally.tally_for(survey_id, field, value)
  end

  def tallies(field)
    Tally.where(survey_id: survey_id, field: field)
  end

  def count_participant
    Tally.record(survey_id, SURVEY_META_KEY, SURVEY_PARTICIPANTS)
  end

  def participants
    tally_for(SURVEY_META_KEY, SURVEY_PARTICIPANTS)
  end
  
  private

  def validate_survey
    fail 'You must include an id field in the survey' if survey_id.blank?
  end

  # def method_missing(method_sym, *arguments, &block)
  #   if @hash['questions'].any? {|h| h['key'] == method_sym.to_s }
  #     nil
  #   else
  #     super
  #   end
  # end
end
