module Serializers
  class Survey < SimpleDelegator
    def as_json
      {
        id: survey_id,
        title: title,
        description: description,
        questions: questions.map {|q| Serializers::Question.new(q).as_json },
        intersections: intersections.map {|i| Serializers::Intersection.new(i).as_json }
      }
    end
  end
end
