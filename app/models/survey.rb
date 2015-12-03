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
  rescue Errno::ENOENT
    raise ActiveRecord::RecordNotFound.new("Survey #{arg} not found")
  end

  def title
    @hash['title']
  end

  def intro
    @hash['intro']
  end
  
  def description
    @hash['description']
  end

  def active?
    !(@hash.key?('active') && @hash['active'] == false)
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

  def intersections
    @hash['intersections']
  end
  
  def record(responses)
    pending = {}

    responses.each do |key, answers|
      next if key == 'id'
      q = questions.detect { |q| q.key == key }
      fail "Question #{key} not found" if q.nil?
      
      q.response_pairs(answers).each do |pair|
        pending[pair.first] ||= []
        pending[pair.first] << pair.last
      end
    end

    pending.each do |key, values|
      values.each do |value|
        next if value.blank?
        Tally.record(survey_id, key, value)
      end
    end

    # now compute the intersection tallies
    intersections.each do |fields|
      key = fields.join('|')
      all_values = fields.map { |f| pending[f] }

      # Skip if any field in the intersection is a nil
      next if all_values.any? { |a| a.nil? }

      # do a Cartesian Product of all combos of each element in each array
      cp = all_values.reduce(&:product).map(&:flatten)

      cp.each do |arr|
        Tally.record(survey_id, key, arr.flatten.join('|'))
      end
    end
  end

  def tally_for(field, value)
    Tally.tally_for(survey_id, field, value)
  end

  def tallies(field)
    Tally.where(survey_id: survey_id, field: field)
  end
  
  def as_json
    {
      id: survey_id,
      title: title,
      description: description,
      questions: questions.map { |q| q.as_json },
      intersections: intersections.map do |fields|
        {
          fields: fields,
          choices: tallies(fields.join('|')).map do |t|
            {
              values: t.value.split('|'),
              count: t.count
            }
          end          
        }
      end
    }
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
