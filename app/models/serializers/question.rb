module Serializers
  class Question < SimpleDelegator
    def choices_json
      ch_out = if freeform?
                 tallies.map do |t|
                   {
                     value: t.value,
                     count: t.count
                   }
                 end
               else
                 choices.map do |ch|
                   Serializers::Choice.new(ch).as_json
                 end
               end

      # FIXME
      if exclusive_combo?
        ch_out << Serializers::Choice.new(::Choice.combination(self)).as_json
      end

      ch_out
    end

    def as_json
      {
        key: key,
        text: text,
        type: question_type,
        choices: choices_json
      }
    end
  end
end
