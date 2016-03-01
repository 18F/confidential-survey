source 'https://rubygems.org'
ruby '2.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyrhino'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'us_web_design_standards' #, git: 'https://github.com/18F/us_web_design_standards_gem.git'
gem 'flutie'
gem 'high_voltage'
gem 'neat', '~> 1.7.0'
gem 'normalize-rails', '~> 3.0.0'
gem 'unicorn'
gem 'title'
gem 'ice_nine'
gem 'redcarpet'
gem 'silencer'
gem 'reek'

group :production do
  gem 'rails_12factor'
  gem 'pg'
end

group :development do
  gem 'refills'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'web-console'
end

group :development, :test do
  gem 'awesome_print'
  gem 'bundler-audit', require: false
  gem 'byebug'
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'i18n-tasks'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.3.0'
  gem 'brakeman', require: false
  gem 'hakiri'
end

group :test do
  gem 'capybara-webkit'
  gem 'formulaic'
  gem 'launchy'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
end

group :staging, :production do
  gem 'rack-timeout'
end
