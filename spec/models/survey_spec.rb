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
        expect { @survey.record('ice-cream' => ['yes', '']) }.to change { Tally.tally_for('ice-cream', 'yes') }.by(1)y
        expect(Tally.where(value: '').count).to eq(0)
      end
      
      it 'should raise an error if it gets multiple valid choices'

      # one day
      it 'should raise an error for an invalid field value'
    end

    context 'for a exclusive-combo field' do
      context 'when the user selects one value' do
        it 'should record that field value in the tally'
      end

      context 'when the user selects multiple values' do
        it 'should not record counts for those values' do
        end

        it 'should record a "combination" value in the tally' do
        end
      end
    end

    context 'for a true multiple field' do

    end

    context 'for a freeform field' do
    end
  end
end
