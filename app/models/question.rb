require 'memoist'

# This is not backed to the database, but just initialized by loading the form
class Question
  extend Memoist
  attr_reader :survey_id

  def initialize(survey_id, hash = {})
    @survey_id = survey_id
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

  def choices
    return nil if freeform?
    @hash['values'].map {|v| Choice.new(self, v) }
  end

  def choices_for_form
    return nil if freeform?

    out = {}
    choices.each do |c|
      out[c.label] = c.value
    end

    out
  end

  memoize :choices, :choices_for_form

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

  # FIXME: move to Serializer
  def as_json
    if freeform?
      ch_out = freeform_tallies_json
    else
      ch_out = choices.map(&:as_json)
      ch_out << Choice.combination(self).as_json if exclusive_combo?
    end

    {
      key: key,
      text: text,
      total: total_responses,
      type: question_type,
      choices: ch_out
    }
  end

  private

  def freeform_tallies_json
    tallies.map do |t|
      {
        value: t.value,
        count: t.count
      }
    end
  end

end
