require "rails_helper"

RSpec.describe Serializers::Question, type: :model do
  describe 'as_json' do
    before { Tally.delete_all }
    let(:survey) { Survey.new('sample-survey') }

    describe 'for a freeform question' do
      subject do
        Tally.record('sample-survey', 'name', 'Foo')
        Tally.record('sample-survey', 'name', 'Bar')
        Tally.record('sample-survey', 'name', 'Foo')
        Serializers::Question.new(survey['name']).as_json
      end

      it 'should return counts for all the responses' do
        expect(subject[:key]).to eq('name')
        expect(subject[:text]).to_not be_blank
        expect(subject[:type]).to eq('freeform')
        expect(subject[:choices]).
          to contain_exactly({value: 'Foo', count: 2},
                             {value: 'Bar', count: 1})
      end
    end

    describe 'for an exclusive question' do
      subject do
        Tally.record('sample-survey', 'ice-cream', 'yes')
        Tally.record('sample-survey', 'ice-cream', 'no')
        Tally.record('sample-survey', 'ice-cream', 'no')
        Serializers::Question.new(survey['ice-cream']).as_json
      end

      it 'should return all responses with counts or not' do
        expect(subject[:key]).to eq('ice-cream')
        expect(subject[:type]).to eq('exclusive')
        expect(subject[:choices]).
          to contain_exactly({value: 'yes', display: 'Yes', count: 1},
                             {value: 'no', display: 'No', count: 2},
                             {value: 'sometimes', display: 'Sometimes', count: 0},
                             {value: 'decline', display: 'Decline to Answer', count: 0})
      end
    end

    describe 'for an exclusive-combo question' do
      subject do
        Tally.record('sample-survey', 'flavor', Choice::COMBINATION_VALUE)
        Tally.record('sample-survey', 'flavor', 'chocolate')
        Tally.record('sample-survey', 'flavor', 'strawberry')
        Serializers::Question.new(survey['flavor']).as_json
      end

      it 'should return all responses and the combo response' do
        expect(subject[:key]).to eq('flavor')
        expect(subject[:type]).to eq('exclusive-combo')
        expect(subject[:choices]).
          to contain_exactly({value: 'chocolate', display: 'Chocolate', count: 1},
                             {value: 'strawberry', display: 'Strawberry', count: 1},
                             {value: 'vanilla', display: 'Vanilla', count: 0},
                             {value: 'rocky', display: 'Rocky Road', count: 0},
                             {value: 'none', display: 'None', count: 0},
                             {value: Choice::COMBINATION_VALUE, display: Choice::COMBINATION_LABEL, count: 1})
      end
    end

    describe 'for a multiple question' do
      subject do
        Tally.record('sample-survey', 'toppings', 'sprinkles')
        Tally.record('sample-survey', 'toppings', 'broccoli')
        Serializers::Question.new(survey['toppings']).as_json
      end

      it 'should return all choices' do
        expect(subject[:key]).to eq('toppings')
        expect(subject[:type]).to eq('multiple')
        expect(subject[:choices]).
          to contain_exactly({value: 'sprinkles', display: 'Sprinkles', count: 1},
                             {value: 'brownies', display: 'Brownies', count: 0},
                             {value: 'chocolate-chips', display: 'Chocolate Chips', count: 0},
                             {value: 'broccoli', display: 'Broccoli', count: 1},
                             {value: 'heath-bar', display: 'Heath Bar', count: 0})
      end
    end
  end
end
