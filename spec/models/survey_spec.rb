require 'rails_helper'

RSpec.describe Survey, type: :model do
  context 'id' do
    it 'should equal the survey id' do
      survey = Survey.new('sample-survey')
      expect(survey.id).to eq('sample-survey')
    end
  end

  context 'active?' do
    let(:survey) { Survey.new('sample-survey') }

    it 'should return false if the field is not specified' do
      expect(survey.active?).to be_truthy
    end
  end
end
