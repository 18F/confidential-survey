require 'rails_helper'

RSpec.describe Intersection do
  describe 'tally_key' do
    let(:intersection) { Intersection.new(nil, %w(foo bar baz)) }

    it 'should concatenate the keys' do
      expect(intersection.tally_key).to eq('foo|bar|baz')
    end
  end
end
