# A model to represent intersection results of choices between several questions
class Intersection < Struct.new(:survey, :keys)
  def tally_key
    keys.join('|')
  end
end
