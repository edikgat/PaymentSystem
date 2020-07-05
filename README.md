# PaymentSystem
## Used Technologies
- [Grape](https://github.com/ruby-grape/grape) For fast and well designed API
- [Swagger](https://swagger.io/) for interactive API documentation
- [Grape::Entity](https://github.com/ruby-grape/grape-entity) for api presenters
- Ruby (2.5.8)
- [RSpec](https://github.com/rspec/rspec) For Unit & API Tests
- [Capybara](https://github.com/teamcapybara/capybara) For UI tests
- Best CSV tool ever - [SmarterCSV](https://github.com/tilo/smarter_csv)
- Custom ideally horizontal scaling API authentication based on JWT [JWT](https://github.com/jwt/ruby-jwt)
- [Pry](https://github.com/pry/pry) For Easy Debugging And Code Inspecting
- [Sidekiq](https://github.com/mperham/sidekiq) for background jobs, [sidekiq-scheduler](https://github.com/moove-it/sidekiq-scheduler) for scheduling
- [Draper](https://github.com/drapergem/draper) for views wrappers
- [Rails 5.2.4.3](https://github.com/rails/rails) - this version was released at May 18, 2020, Rails 6 was incopable with some technologies that are using here
- [Devise](https://github.com/heartcombo/devise) for simple UI authentication
- [state_machine](https://github.com/pluginaweek/state_machine) for different transaction types statuses
- [Bootstrap](https://getbootstrap.com/)

## Patterns & Rails Enhancements
- Service Objects - based on Command (for authentication) & Strategy for user input processing
- Convention Over Configuration principle used for complex user params processing at API
- Form Objects - used together with service objects - they encapsulates validation logic to make new Transactions approved, or move them to error state (Context pattern with service strategy)
- Special State Machine for each transaction type - for more flexibility
- Presenters - including special presenter for form result
- Wrappers (Draper's decorators)
- MySQL Enum instead of rails enum
- Foreign Keys for dependent tables
- STI for Transactions
- CSV import works using also Service Objects & Form Objects
- Optimistic locks for merchants & transactions to prevent double changes

## What It Does
- System support 4 different types of transactions
- Transactions can be dependent to each other
- Transactions should be created and moved to status 'error' when they are partially invalid, so we cannot use plain rails validations practice, and should have validations at forms & models
- Merchants can moved to inactive status - so system will not create new transactions for such merchants
- To remove merchant - merchant should have 0 transactions, that can be done after removing transactions by schedule
- User will be able to upload csv with different fields in different order, but some of them are required
- Removing Job runs by schedule every hour, and remove all transactions that related to authorize transactions that were created more than one hour ago, this is needed to have referential integrity
- System has different UI's for admins and merchants
- System has seeds for basic data

## Code Analysis
- Tests Coverage 98% by [SimpleCov](https://github.com/colszowka/simplecov), including browser tests, api tests, and unit tests for services
- Code Inspected by [RuboCop](https://github.com/rubocop-hq/rubocop), no offenses detected
- Code Inspected for security vulnerabilities by [Brakeman](https://github.com/presidentbeef/brakeman), no warnings found

## Requirements
- Ruby = 2.5.8
- MySQL
- Redis

## Setup
- Go to project's folder in your terminal
- set `PaymentSystem_DATABASE_PASSWORD`
- Run `bundle`
- Run `rake db:setup`

## Run API
- Start server `rails s`
- Start background job `bundle exec sidekiq`
- Go to `http://localhost:3000/`

## API Documentation
- Start server `rails s`
- Go to `http://localhost:3000/documentation`

## Background Processes Monitoring
- Start server `rails s`
- Go to `http://localhost:3000/sidekiq`

## Seeds
- `rake db:seed`

## Running tests
- `rspec spec/`

## Tests Coverage Report
- Not At `.gitignore` for easy review
- Open In Browser `coverage/index.html`

## Code Quality report
- Run `rubocop`
