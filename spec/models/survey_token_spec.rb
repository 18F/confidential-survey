require 'rails_helper'

RSpec.describe SurveyToken do
  before { SurveyToken.delete_all }
  
  describe 'generate' do
    it 'should return a token string and save a new token for a survey' do
      token = SurveyToken.generate('sample-survey')

      expect(token).to be_a(String)
      expect(token).to_not be_blank
      expect(SurveyToken.where(survey_id: 'sample-survey', token: token).first).to_not be_nil
    end
  end

  describe 'valid?' do
    it 'should return true if the token is found for the survey' do
      token = SurveyToken.generate('sample-survey')
      expect(SurveyToken.valid?('sample-survey', token)).to be_truthy
    end
    
    it 'should return false if the token is not found' do
      expect(SurveyToken.valid?('sample-survey', 'foo')).to be_falsey
    end
    
    it 'should return false if the token is found for a different survey' do
      token = SurveyToken.generate('sample-survey')
      expect(SurveyToken.valid?('foo', token)).to be_falsey
    end    
  end

  describe 'revoke' do
    it 'should destroy the token if it exists' do
      token = SurveyToken.generate('sample-survey')
      expect(SurveyToken.count).to eq(1)
      SurveyToken.revoke('sample-survey', token)
      expect(SurveyToken.count).to eq(0)
    end

    it "should not destroy the token if it's assigned to another survey" do
      token = SurveyToken.generate('sample-survey')
      expect(SurveyToken.count).to eq(1)
      SurveyToken.revoke('foo', token)
      expect(SurveyToken.count).to eq(1)
    end
    
    it 'should not raise an error if the token is not found' do
      expect { SurveyToken.revoke('foo', 'bazquux') }.to_not raise_error
    end
  end

  describe 'revoke_all_for_survey' do
    it 'should delete all tokens for a specific survey' do
      SurveyToken.generate('survey1')
      SurveyToken.generate('survey1')
      SurveyToken.generate('survey2')

      expect(SurveyToken.count).to eq(3)
      SurveyToken.revoke_all_for_survey('survey1')
      expect(SurveyToken.count).to eq(1)
    end
  end
end
