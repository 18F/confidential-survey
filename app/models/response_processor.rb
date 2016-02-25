class ResponseProcessor < Struct.new(:params, :survey)
  def perform
    pending = record_answers(params)
    record_intersections(pending)
    survey.count_participant
  end

  private

  def survey_id
    survey.survey_id
  end

  def record_answers(responses)
    pending = {}

    responses.each do |key, answers|
      next if key == 'id'
      question = survey[key]
      fail SurveyError, "Question #{key} not found" if question.nil?

      question.response_pairs(answers).each do |pair|
        fail SurveyError, "Invalid choice '#{pair.last}' for question #{key}" unless question.valid_choice_value?(pair.last)
        
        pending[pair.first] ||= []
        pending[pair.first] << pair.last
      end
    end

    pending.each do |key, values|
      values.each do |value|
        next if value.blank?
        Tally.record(survey_id, key, value)
      end
    end

    pending
  end

  def record_intersections(pending)
    # now compute the intersection tallies
    survey.intersections.each do |intersection|
      key = intersection.tally_key
      all_values = intersection.keys.map {|f| pending[f] }

      # Skip if any field in the intersection is a nil
      # rubocop:disable Style/SymbolProc
      next if all_values.any? {|x| x.nil? }
      # rubocop:enable Style/SymbolProc

      # do a Cartesian Product of all combos of each element in each array
      cp = all_values.reduce(&:product).map(&:flatten)

      cp.each do |arr|
        Tally.record(survey_id, key, arr.flatten.join('|'))
      end
    end
  end
end
