require 'rails_helper'
require 'brakeman'

RSpec.feature "Security" do
  context 'Static code analysis and check for CVEs' do
    before(:all) do
      @tracker = Brakeman.run(Rails.root.to_s)
    end

    let(:brakeman_warnings) { @tracker.filtered_warnings }

    scenario "The site has zero Brakeman security warnings" do
      expect(brakeman_warnings.length).
        to eq(0), "Expected 0 security warnings, got: \n #{brakeman_warnings.map(&:to_s)}."
    end
  end
end
