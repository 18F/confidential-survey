# A model to represent intersection results of choices between several questions
class Intersection < Struct.new(:survey, :keys)
  def tally_key
    keys.join('|')
  end

  def survey_id
    survey.id
  end
end
