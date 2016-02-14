module Serializers
  class Intersection < SimpleDelegator
    def tallies
      Tally.where(survey_id: survey_id, field: tally_key)
    end
    
    def as_json
      {
        fields: keys,
        choices: tallies.map do |t|
          {
            values: t.value.split('|'),
            count: t.count
          }
        end
      }
    end
  end
end
