require 'rails_helper'

RSpec.describe ResponseProcessor, type: :model do
  describe 'perform' do
    before(:all) do
      @survey = Survey.new('sample-survey')
    end

    let(:params) { {} }
    let(:processor) { ResponseProcessor.new(params, @survey) }
    
    context 'for an exclusive field' do
      context 'when there is single nonblank response' do
        let(:params) { {'ice-cream' => ['yes', '']} }        

        it 'should record a tally' do
          expect { processor.perform }.to change { @survey.tally_for('ice-cream', 'yes') }.by(1)
          expect(Tally.where(value: '').count).to eq(0)
        end
      end

      context 'when there are multiple nonblank responses' do
        let(:params) { {'ice-cream' => %w(yes no)} }
        
        it 'should raise an error if it gets multiple valid choices' do
          expect { processor.perform }.to raise_error(RuntimeError)
        end
      end
      
      # one day
      it 'should raise an error for an invalid field value'
    end

    context 'for a exclusive-combo field' do
      context 'when the user selects one value' do
        let(:params) { {'flavor' => ['chocolate']} }
        
        it 'should record that field value in the tally' do
          expect { processor.perform }.
            to change { @survey.tally_for('flavor', 'chocolate') }.by(1)
        end
      end

      context 'when the user selects multiple values' do
        let(:params) { {'flavor' => %w(chocolate vanilla)} }
        subject { processor.perform }

        it 'should not record counts for those values' do
          expect { subject }.to_not change { @survey.tally_for('flavor', 'vanilla') }
          expect { subject }.to_not change { @survey.tally_for('flavor', 'chocolate') }
        end

        it 'should record a "combination" value in the tally' do
          expect { subject }.
            to change { @survey.tally_for('flavor', Choice::COMBINATION_VALUE) }.by(1)
        end
      end
    end

    context 'for a true multiple field' do
      let(:params) { {'desserts' => %w(cake cookies)} }
      subject { processor.perform }

      it 'should update the tally for each value' do
        c_cookies = @survey.tally_for('desserts', 'cookies')
        expect { subject }.to change { @survey.tally_for('desserts', 'cake') }.by(1)
        expect(@survey.tally_for('desserts', 'cookies')).to eq(c_cookies + 1)
      end

      it 'should not update the tally for the combined value' do
        expect { subject }.
          to_not change { @survey.tally_for('dessgerts', Choice::COMBINATION_VALUE) }
      end
    end

    context 'for a freeform field' do
      context 'when the field is not blank' do
        let(:params) { {'name' => 'Jacob Harris'} }
        it 'should record the field unchanged' do
          expect { processor.perform }.
            to change { @survey.tally_for('name', 'Jacob Harris') }.by(1)
        end
      end

      context 'when the field is blank' do
        let(:params) { {'name' => ''} }
        
        it 'should not record if the value is blank' do
        expect { processor.perform }.to_not change { Tally.count }
        end
      end
    end
    
    context 'for an intersection' do
      before(:all) do
        Tally.delete_all
        params = {'flavor' => ['chocolate'], 'toppings' => ['sprinkles', 'hot-fudge'] }
        ResponseProcessor.new(params, @survey).perform
        params = { 'flavor' => ['chocolate'], 'toppings' => ['hot-fudge'] }
        ResponseProcessor.new(params, @survey).perform
      end

      it 'should count the intersection of both elements' do
        expect(@survey.tally_for('flavor', 'chocolate')).to eq(2)
        expect(@survey.tally_for('flavor|toppings', 'chocolate|sprinkles')).to eq(1)
      end
    end
  end
end
