module Serializers
  class Choice < SimpleDelegator
    def as_json
      {
        value: value,
        display: label,
        count: count
      }
    end
  end
end
