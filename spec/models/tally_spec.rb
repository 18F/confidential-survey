require 'rails_helper'

RSpec.describe Tally, type: :model do
  before(:all) do
    @survey_id = 'abc'
  end

  describe 'validations' do
    it 'should not allow a blank survey_id' do
      expect(Tally.new(field: 'foo', value: 'bar', count: 10)).to_not be_valid
    end

    it 'should not allow blank fields' do
      expect(Tally.new(survey_id: @survey_id, field: nil, value: 'b', count: 10)).to_not be_valid
    end

    it 'should not allow blank values' do
      expect(Tally.new(survey_id: @survey_id, field: 'a', value: nil, count: 5)).to_not be_valid
    end

    it 'should not allow negative counts' do
      expect(Tally.new(survey_id: @survey_id, field: 'a', value: 'b', count: -1)).to_not be_valid
    end
  end

  describe 'Tally#increment' do
    context 'when there is no record for the field/value' do
      before(:all) do
        Tally.delete_all
        Tally.record(@survey_id, 'foo', 'bar')
      end

      it 'should create a record for the field/value with count 1' do
        expect(Tally.where(survey_id: @survey_id, field: 'foo', value: 'bar').count).to eq(1)
      end
    end

    context 'when there is a record for the field/value' do
      before(:all) do
        Tally.delete_all
        create(:tally, survey_id: @survey_id, field: 'foo', value: 'bar', count: 83)
      end

      it 'should increment the count for that field/value pair' do
        expect{ Tally.record(@survey_id, 'foo', 'bar') }.
          to change { Tally.tally_for(@survey_id, 'foo', 'bar') }.by(1)
      end

      it 'should not create a new field record' do
        expect { Tally.record(@survey_id, 'foo', 'bar') }.
          to_not change { Tally.count }
      end
    end
  end

  describe 'access_methods' do
    before(:all) do
      Tally.delete_all
      @foo1 = Tally.create(survey_id: @survey_id, field: 'foo', value: 'abc', count: 5)
      @foo2 = Tally.create(survey_id: @survey_id, field: 'foo', value: 'def', count: 2)
      @bar = Tally.create(survey_id: @survey_id, field: 'bar', value: 'baz', count: 5)
    end

    describe 'tally_for' do
      it 'should return the count if it exists' do
        expect(Tally.tally_for(@survey_id, 'foo', 'def')).to eq(2)
      end

      it 'should return 0 otherwise' do
        expect(Tally.tally_for(@survey_id, 'foo', 'xyz')).to eq(0)
      end
    end

    describe 'tallies_for' do
      it 'should return all tallies that match the field' do
        expect(Tally.tallies_for(@survey_id, 'foo')).
          to contain_exactly(@foo1, @foo2)
      end

      it 'should return an empty array if none match' do
        expect(Tally.tallies_for(@survey_id, 'quux')).to eq([])
      end
    end

    describe 'total_for' do
      it 'should return the totals it there are tallies' do
        expect(Tally.total_for(@survey_id, 'foo')).to eq(7)
      end

      it 'should return 0 otherwise' do
        expect(Tally.total_for(@survey_id, 'quux')).to eq(0)
      end
    end
  end
end
