require 'rails_helper'

RSpec.describe Survey, type: :model do
  context 'active?' do
    let(:survey) { Survey.new('sample-survey') }

    it 'should return false if the field is not specified' do
      expect(survey.active?).to be_truthy
    end
  end

  context 'valid_token?' do
    let(:survey) { Survey.new('sample-survey') }

    it 'should return true if the token is found' do
      token = SurveyToken.generate('sample-survey')
      expect(survey.valid_token?(token)).to be_truthy
    end

    it 'should return false if the token is not found' do
      expect(survey.valid_token?('foobar')).to be_falsey
    end
  end
end
