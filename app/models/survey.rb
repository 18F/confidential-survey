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

  def title
    @hash['title']
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

  def description
    @hash['description']
  end

  def active?
    !(@hash.key?('active') && @hash['active'] == false)
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
 
