# This is not backed to the database, but just initialized by loading the form
class Question
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
end
