# This is not backed to the database, but just initialized by loading the form
class Question
  attr_reader :survey

  def initialize(survey, hash = {})
    @survey = survey
    @hash = hash.dup.freeze
  end

  def key
    @hash['key']
  end

  def text
    @hash['text']
  end

  def hint
    @hash['hint']
  end

  def description
    @hash['description']
  end

  def question_type
    @hash['type']
  end

  def survey_id
    @survey.survey_id
  end

  def choices
    return nil if freeform?

    if @choices.nil?
      @choices = @hash['values'].map {|v| Choice.new(self, v) }
    end

    @choices
  end

  def tallies
    Tally.tallies_for(survey_id, key)
  end

  def total_responses
    Tally.total_for(survey_id, key)
  end

  def freeform?
    question_type == 'freeform'
  end

  def exclusive?
    question_type == 'exclusive'
  end

  def exclusive_combo?
    question_type == 'exclusive-combo'
  end

  def multiple?
    question_type == 'multiple'
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def response_pairs(responses)
    responses = [responses] unless responses.is_a?(Array)
    responses = responses.reject(&:blank?)

    case
    when freeform?
      [[key, responses.first]]
    when exclusive?
      fail 'Multiple responses for an exclusive question' if responses.length > 1
      [[key, responses.first]]
    when exclusive_combo?
      if responses.length > 1
        [[key, Choice::COMBINATION_VALUE]]
      else
        [[key, responses.first]]
      end
    when multiple?
      responses.map do |r|
        [key, r]
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
