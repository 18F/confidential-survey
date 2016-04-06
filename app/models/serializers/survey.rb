module Serializers
  class Survey < SimpleDelegator
    def as_json
      out = {
        id: survey_id,
        title: title,
        description: description,
        participants: participants
      }

      unless active?
        out[:questions] = questions.map {|q| Serializers::Question.new(q).as_json }
        out[:intersections] = intersections.map {|i| Serializers::Intersection.new(i).as_json }
      end

      out
    end
  end
end
