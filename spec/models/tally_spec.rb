require 'rails_helper'

RSpec.describe Tally, type: :model do
  describe 'validations' do
    it 'should not allow blank fields' do
      expect(Tally.new(field: nil, value: 'b', count: 10)).to_not be_valid
    end

    it 'should not allow blank values' do
      expect(Tally.new(field: 'a', value: nil, count: 5)).to_not be_valid
    end

    it 'should not allow negative counts' do
      expect(Tally.new(field: 'a', value: 'b', count: -1)).to_not be_valid
    end

    it 'should ensure field/value rows are unique' do
      Tally.delete_all
      t = create(:tally)
      expect(Tally.new(field: t.field, value: t.value, count: 83)).to_not be_valid
    end
  end

  describe 'Tally#increment' do
    context 'when there is no record for the field/value' do
      before(:all) { Tally.delete_all; Tally.record('foo', 'bar') }

      it 'should create a record for the field/value with count 1' do
        expect(Tally.where(field: 'foo', value: 'bar').count).to eq(1)
      end
    end

    context 'when there is a record for the field/value' do
      before(:all) do 
        Tally.delete_all
        create(:tally, field: 'foo', value: 'bar', count: 83)
      end

      it 'should increment the count for that field/value pair' do
        expect{Tally.record('foo', 'bar')}.to change {Tally.tally_for('foo', 'bar')}.by(1)
      end

      it 'should not create a new field record' do
        expect{Tally.record('foo', 'bar')}.to_not change {Tally.count}
      end
    end
  end
end
