require 'rails_helper'

RSpec.describe Serializers::Intersection, type: :model do
  describe 'as_json' do
    before do
      Tally.delete_all
      @survey = Survey.new('sample-survey')
      Tally.record('sample-survey', 'flavor|toppings', 'chocolate|sprinkles')
      Tally.record('sample-survey', 'flavor|toppings', 'chocolate|brownies')
      Tally.record('sample-survey', 'flavor|toppings', 'chocolate|sprinkles')
      intersection = Intersection.new(@survey, %w(flavor toppings))
      serializer = Serializers::Intersection.new(intersection)
      @out = serializer.as_json
    end

    it 'should properly return intersections' do
      expect(@out[:fields]).to eq(%w(flavor toppings))

      # rubocop:disable Style/BracesAroundHashParameters
      expect(@out[:choices]).to contain_exactly(
        {values: %w(chocolate sprinkles), count: 2},
        {values: %w(chocolate brownies), count: 1})
      # rubocop:enable Style/BracesAroundHashParameters
    end
  end
end
