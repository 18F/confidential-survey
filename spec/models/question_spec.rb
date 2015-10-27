require 'rails_helper'

describe Question do
  describe "#initialize" do
    let(:hash) do 
      { 'key': 'race',
        'text': 'What is your racial identity?',
        'type': 'checkbox',
        'values': [
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

    subject { Question.new(hash) }

    specify { expect(subject.key).to eq(hash['key']) }
    specify { expect(subject.text).to eq(hash['text']) }
  end
end
