require 'rails_helper'

RSpec.describe Survey, type: :model do
  describe 'record' do
    before(:all) do
      @survey = Survey.new('sample-survey')
    end

    context 'active?' do
      it 'should return false if the field is not specified' do
        expect(@survey.active?).to be_truthy
      end
    end

    context 'for an exclusive field' do
      it 'should record a tally' do
        expect { @survey.record('ice-cream' => ['yes', '']) }.to change { @survey.tally_for('ice-cream', 'yes') }.by(1)
        expect(Tally.where(value: '').count).to eq(0)
      end

      it 'should raise an error if it gets multiple valid choices' do
        expect { @survey.record('ice-cream' => ['yes', 'no']) }.to raise_error(RuntimeError)
      end

      # one day
      it 'should raise an error for an invalid field value'
    end

    context 'for a exclusive-combo field' do
      context 'when the user selects one value' do
        it 'should record that field value in the tally' do
          expect { @survey.record('flavor' => ['chocolate']) }.to change { @survey.tally_for('flavor', 'chocolate') }.by(1)
        end
      end

      context 'when the user selects multiple values' do
        subject { @survey.record('flavor' => ['chocolate', 'vanilla']) }

        it 'should not record counts for those values' do
          expect { subject }.to_not change { @survey.tally_for('flavor', 'vanilla') }
          expect { subject }.to_not change { @survey.tally_for('flavor', 'chocolate') }
        end

        it 'should record a "combination" value in the tally' do
          expect { subject }.to change { @survey.tally_for('flavor', Question::COMBINATION_VALUE) }.by(1)
        end
      end
    end

    context 'for a true multiple field' do
      subject { @survey.record('desserts' => ['cake', 'cookies']) }

      it 'should update the tally for each value' do
        c_cookies = @survey.tally_for('desserts', 'cookies')
        expect { subject }.to change { @survey.tally_for('desserts', 'cake') }.by(1)
        expect(@survey.tally_for('desserts', 'cookies')).to eq(c_cookies + 1)
      end

      it 'should not update the tally for the combined value' do
        expect { subject }.to_not change { @survey.tally_for('desserts', Question::COMBINATION_VALUE) }
      end
    end

    context 'for a freeform field' do
      it "should record the field unchanged" do
        expect { @survey.record('name' => 'Jacob Harris') }.to change { @survey.tally_for('name', 'Jacob Harris') }.by(1)
      end

      it 'should not record if the value is blank' do
        expect { @survey.record('name' => '') }.to_not change { Tally.count }
      end
    end

    context 'for an intersection' do
      before(:all) do
        Tally.delete_all
        @survey.record('flavor' => ['chocolate'], 'toppings' => ['sprinkles', 'hot-fudge'])
        @survey.record('flavor' => ['chocolate'], 'toppings' => ['hot-fudge'])
      end

      it 'should count the intersection of both elements' do
        expect(@survey.tally_for('flavor', 'chocolate')).to eq(2)
        expect(@survey.tally_for('flavor|toppings', 'chocolate|sprinkles')).to eq(1)
      end
    end
  end
end
