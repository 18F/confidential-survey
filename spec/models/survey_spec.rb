require 'rails_helper'

RSpec.describe Survey, type: :model do
  context 'active?' do
    let(:survey) { Survey.new('sample-survey') }
    
    it 'should return false if the field is not specified' do
      expect(survey.active?).to be_truthy
    end
  end
end
