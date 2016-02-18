# frozen_string_literal: true
class Choice
  attr_reader :question, :value, :label

  COMBINATION_VALUE = 'combination'.freeze
  COMBINATION_LABEL = 'Combination'.freeze

  def initialize(question, value, label = nil)
    @question = question

    if label.nil?
      initialize_from_split(value)
    else
      @value = value
      @label = label
    end
  end

  def initialize_from_split(value)
    # YAML translates these to booleans
    if value == true
      value = 'Yes'
    elsif value == false
      value = 'No'
    end

    @value, @label = value.split('|', 2)

    return unless @label.nil?

    @label = value
    @value = @label.parameterize
  end

  def self.combination(question)
    new(question, COMBINATION_VALUE, COMBINATION_LABEL)
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
end
