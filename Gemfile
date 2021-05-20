# frozen_string_literal: true

source('https://rubygems.org')
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby('2.5.8')

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem('coffee-rails', '~> 4.2')
gem('mysql2', '>= 0.4.4', '< 0.6.0')
gem('nokogiri')
gem('puma', '~> 4.3')
gem('rails', '~> 5.2.4', '>= 5.2.4.3')
gem('sass-rails', '~> 5.0')
gem('turbolinks', '~> 5')
gem('uglifier', '>= 1.3.0')

gem('activerecord-mysql-enum', git: 'git@github.com:edikgat/activerecord-mysql-enum.git', branch: 'rails-5.2')
gem('bootsnap', '>= 1.1.0', require: false)
gem('bootstrap-generators', '~> 3.3.4')
gem('bootstrap-sass', '~> 3.4.1')
gem('devise')
gem('jquery-rails')
gem('record_tag_helper', '~> 1.0')
gem('sassc-rails', '>= 2.1.0')
gem('simple_form', '~> 5.0.0')

gem('draper')
gem('grape')
gem('grape-entity')
gem('grape-swagger')
gem('grape-swagger-rails')
gem('hashie-forbidden_attributes')
gem('jwt')
gem('sidekiq')
gem('sidekiq-scheduler')
gem('slim-rails')
gem('smarter_csv')
gem('state_machine')
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'grape_on_rails_routes'
  gem 'pry-rails'
  gem 'timecop'
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner-active_record'
  gem 'mocha', '0.14.0', require: false
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webdrivers', '~> 4.0'
end

group :development do
  gem 'brakeman'
  gem 'rubocop', '~> 0.51.0', require: false
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem('tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby])
