require 'rails_helper'

RSpec.describe Survey, type: :model do
  describe 'record' do
    #########################################################
    # let(:responses) do                                    #
    #   {                                                   #
    #     'ice-cream' => ['yes', ''],                       #
    #     'favorite-flavor' => ['chocolate'],               #
    #     'favorite-toppings' => ['brownies', 'sprinkles'], #
    #     'desserts' => ['cupcakes', 'cake', 'candy', ''],  #
    #     'name' => ['This is a test']                      #
    #   }                                                   #
    # end                                                   #
    #########################################################
    
    before(:all) do
      @survey = Survey.new('sample-survey')
    end

    subject { @survey.record(responses) }

    context 'for an exclusive field' do
      it 'should record a tally' do
        expect { @survey.record('ice-cream' => ['yes', '']) }.to change { Tally.tally_for('ice-cream', 'yes') }.by(1)
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
          expect { @survey.record('favorite-flavor' => ['chocolate']) }.to change { Tally.tally_for('favorite-flavor', 'chocolate') }.by(1)
        end
      end

      context 'when the user selects multiple values' do
        subject { @survey.record('favorite-flavor' => ['chocolate', 'vanilla']) } 

        it 'should not record counts for those values' do
          expect { subject }.to_not change { Tally.tally_for('favorite-flavor', 'vanilla') }
          expect { subject }.to_not change { Tally.tally_for('favorite-flavor', 'chocolate') }
        end

        it 'should record a "combination" value in the tally' do
          expect { subject }.to change { Tally.tally_for('favorite-flavor', Question::COMBINATION_VALUE) }.by(1)
        end
      end
    end

    context 'for a true multiple field' do
      subject { @survey.record('desserts' => ['cake', 'cookies']) }

      it 'should update the tally for each value' do
        c_cookies = Tally.tally_for('desserts', 'cookies')
        expect { subject }.to change { Tally.tally_for('desserts', 'cake') }.by(1)
        expect(Tally.tally_for('desserts', 'cookies')).to eq(c_cookies + 1)
      end

      it 'should not update the tally for the combined value' do
        expect { subject }.to_not change { Tally.tally_for('desserts', Question::COMBINATION_VALUE) }
      end
    end

    context 'for a freeform field' do
      it "should record the field unchanged" do
        expect { @survey.record('name' => 'Jacob Harris') }.to change { Tally.tally_for('name', 'Jacob Harris') }.by(1)
      end
    end
  end
end
