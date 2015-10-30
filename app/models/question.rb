require 'memoist'

# This is not backed to the database, but just initialized by loading the form
class Question
  extend Memoist

  def initialize(hash={})
    @hash = hash.dup.freeze
  end

  def key
    @hash['key']
  end
  
  def text
    @hash['text']
  end

  def question_type
    @hash['type']
  end

  def choices
    return nil if freeform?

    out = {}
    choices_for_form.each do |label, key|
      out[key] = label
    end
  end

  def choices_for_form
    return nil if freeform?
    out = {}

    @hash['values'].each do |v|
      key, label = nil

      case v
      when String
        key, label = v.split("|", 2)
        if label.nil?
          label = key
          key = label.parameterize
        end
      when true
        key = 'yes'
        label = 'Yes'
      when false
        key = 'no'
        label = 'No'
      end

      out[label] = key
    end

    out
  end
  memoize :choices, :choices_for_form

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

  def record(responses)
    responses = [responses] unless responses.is_a?(Array)
    responses = responses.reject {|r| r.blank? }

    case
    when freeform?
      Tally.record(key, responses.first)
    when exclusive?
      raise "Multple responses for an exclusive question" if responses.length > 1
      Tally.record(key, responses.first)
    when exclusive_combo?
      if responses.length > 1
        Tally.record(key, 'multiple')
      else
        Tally.record(key, responses.first)
      end
    when multiple?
      responses.each do |r|
        Tally.record(key, r)
      end
    end
  end
end
