require 'rails_helper'

RSpec.describe Choice do
  describe 'initialize' do
    let(:survey) { double('Survey', survey_id: 'ice-cream') }
    let(:question) { Question.new(survey, key: 'flavor') }

    it 'should split a string into value and label' do
      c = Choice.new(question, 'chocolate|Chocolate')
      expect(c.question).to eq(question)
      expect(c.survey_id).to eq(question.survey_id)
      expect(c.key).to eq(question.key)
      expect(c.value).to eq('chocolate')
      expect(c.label).to eq('Chocolate')
    end

    it 'should save a parameterized key if one is not provided' do
      c = Choice.new(question, 'Rocky Road')
      expect(c.question).to eq(question)
      expect(c.label).to eq('Rocky Road')
      expect(c.value).to eq('rocky-road')
    end

    it 'should save Yes if YAML sends true as value' do
      c = Choice.new(question, true)
      expect(c.question).to eq(question)
      expect(c.label).to eq('Yes')
      expect(c.value).to eq('yes')
    end

    it 'should save No if YAML sends true as value' do
      c = Choice.new(question, false)
      expect(c.question).to eq(question)
      expect(c.label).to eq('No')
      expect(c.value).to eq('no')
    end
  end
end
