require 'rails_helper'

RSpec.feature 'user takes token-protected survey', type: :feature do
  scenario 'submitting a token-based survey' do
    Tally.delete_all
    token = SurveyToken.generate('sample-survey')

    survey = Survey.new('sample-survey')
    visit "/surveys/sample-survey?token=#{token}"

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

    expect(page).to have_content('Thank you for participating in this survey')

    # Check that we have responses
    # rubocop:disable Style/WordArray
    [['ice-cream', 'yes'], ['flavor', 'combination'],
     ['toppings', 'sprinkles'], ['toppings', 'brownies'],
     ['desserts', 'cake'], ['name', 'Blue Bell']].each do |key, value|
      count = Tally.tally_for('sample-survey', key, value)
      # puts "#{key} #{value}: #{count}"
      expect(count).to eq(1), "Expected to record tally for #{key}=#{value}"
    end
    # rubocop:enable Style/WordArray

    expect(survey.participants).to eq(1)
  end
end

RSpec.feature 'user takes http-auth-protected survey' do
  include_context 'When authenticated'
  
  scenario 'submitting a http-auth survey' do
    Tally.delete_all
    
    survey = Survey.new('auth-survey')
    
    visit '/surveys/auth-survey'
    
    expect(page).to have_content('Killer Robot Survey')
    expect(page).to have_content('This is another fake survey to test HTTP authentication')
    
    choose('Yes')
    check('Lasers')
    check('Harpoon')
    
    click_on('Submit')
    
    expect(page).to have_content('Thank you for participating in this survey')
    
    # rubocop:disable Style/WordArray
    [['like', 'yes'], ['attachments', 'laser'], ['attachments', 'harpoon']].each do |key, value|
      count = Tally.tally_for('auth-survey', key, value)
      # puts "#{key} #{value}: #{count}"
      expect(count).to eq(1), "Expected to record tally for #{key}=#{value}"
    end
    # rubocop:enable Style/WordArray
    
    expect(survey.participants).to eq(1)
  end
end
