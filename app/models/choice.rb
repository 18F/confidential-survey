# frozen_string_literal: true
class Choice
  attr_reader :question, :value, :label

  COMBINATION_VALUE = 'combination'.freeze

  def initialize(question, str)
    @question = question

    # YAML translates these to booleans
    if str == true
      str = 'Yes'
    elsif str == false
      str = 'No'
    end

    @value, @label = str.split('|', 2)

    if @label.nil?
      @label = str
      @value = @label.parameterize
    end
  end

  def self.combination(question)
    new(question, COMBINATION_VALUE)
  end

  def survey_id
    question.survey_id
  end

  def key
    question.key
  end

  def tally_for(value)
    Tally.tally_for(survey_id, key, value)
  end

  def count
    tally_for(value)
  end

  def as_json
    {
      key: key,
      value: value,
      count: count
    }
  end
end
