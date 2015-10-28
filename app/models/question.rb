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
    @hash['values'].map do |v|
      v.split("|")
    end
  end
end
