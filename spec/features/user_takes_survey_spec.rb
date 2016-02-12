require 'rails_helper'

RSpec.feature 'user takes survey', type: :feature do
  scenario 'submitting a survey' do
    Tally.delete_all
    visit '/surveys/sample-survey'

    expect(page).to have_content('Ice Cream Survey')
    expect(page).to have_content('This is a sample survey to see how much you really love ice cream.')

    choose('Yes')
    check('Strawberry')
    check('Vanilla')
    check('Sprinkles')
    check('Brownies')
    check('Cake')
    fill_in('What is the brand of your favorite ice cream?', with: 'Blue Bell')

    click_on('Submit')

    # Check that we have responses
    # rubocop:disable Style/WordArray
    [['ice-cream', 'yes'], ['flavor', 'combination'],
     ['toppings', 'sprinkles'], ['toppings', 'brownies'],
     ['desserts', 'cake'], ['name', 'Blue Bell']].each do |key, value|
      count = Tally.tally_for('sample-survey', key, value)
      #puts "#{key} #{value}: #{count}"
      expect(count).to eq(1)
    end
    # rubocop:enable Style/WordArray

    expect(page).to have_content('Thank you for participating in this survey')
  end
end
