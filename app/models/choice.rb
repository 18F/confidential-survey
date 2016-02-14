# frozen_string_literal: true
class Choice
  attr_reader :question, :value, :label

  COMBINATION_VALUE = 'combination'.freeze
  COMBINATION_LABEL = 'Combination'.freeze
  
  def initialize(question, value, label=nil)
    @question = question

    unless label.nil?
      @value = value
      @label = label
    else
      initialize_from_split(question, value)
    end
  end
  
  def initialize_from_split(question, value)
    # YAML translates these to booleans
    if value == true
      value = 'Yes'
    elsif value == false
      value = 'No'
    end
    
    @value, @label = value.split('|', 2)
    
    if @label.nil?
      @label = value
      @value = @label.parameterize
    end
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

  def as_json
    {
      value: value,
      display: label,
      count: count
    }
  end
end
