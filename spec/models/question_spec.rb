require 'rails_helper'

describe Question do
  describe '#initialize' do
    let(:survey) { double('Survey', survey_id: 'survey1') }
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

    subject { Question.new(survey, hash) }

    specify { expect(subject.survey_id).to eq(survey.survey_id) }
    specify { expect(subject.key).to eq(hash['key']) }
    specify { expect(subject.text).to eq(hash['text']) }
    specify { expect(subject.question_type).to eq(hash['type']) }
  end
end
