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
      key, label = v.split("|", 2)
      out[label] = key.nil? ? label : key  # use 
    end

    out
  end
end
