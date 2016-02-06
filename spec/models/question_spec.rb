require 'rails_helper'

describe Question do
  describe '#initialize' do
    let(:survey_id) { 'survey1' }
    let(:hash) do
      {'key' => 'race',
       'text' => 'What is your racial identity?',
       'type' => 'exclusive',
       'values' => [
         'indian|American Indian or Alaska Native',
         'asian|Asian',
         'black|Black or African American',
         'polynesian|Native Hawaiian or other Pacific Islander',
         'white|White',
         'other|Other',
         'decline|Prefer Not To Answer'
       ]
      }
    end

    subject { Question.new(survey_id, hash) }

    specify { expect(subject.survey_id).to eq(survey_id) }
    specify { expect(subject.key).to eq(hash['key']) }
    specify { expect(subject.text).to eq(hash['text']) }
    specify { expect(subject.question_type).to eq(hash['type']) }

    it 'should extract the questions into a hash' do
      expect(subject.choices_for_form).to be_a(Hash)
      expect(subject.choices_for_form['American Indian or Alaska Native']).to eq('indian')
    end

    it 'should parameterize fields if not provided' do
      hash2 = {
        'key' => 'foo',
        'type' => 'exclusive',
        'values' => ['Yes', 'No', 'Decline To Answer']}

      q = Question.new(survey_id, hash2)
      expect(q.choices_for_form['Yes']).to eq('yes')
      expect(q.choices_for_form['Decline To Answer']).to eq('decline-to-answer')
    end
  end
end
