# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '5.1.6'

gem 'listen'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'modernizr-rails'
gem 'rails-timeago', '~> 2.0'

gem 'jsonapi-resources'
gem 'pundit-resources', git: 'https://github.com/wharehauora/pundit-resources', branch: 'rails-5.1'
gem 'jbuilder'

# # bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc

# Use Postgresql as the database for Active Record
gem 'pg', '< 1.0.0'

# Using puma as server
gem 'puma'

# for logins
gem 'devise'
gem 'devise_invitable', '~> 1.7.0'

# soft delete of records
gem 'paranoia', '~> 2.2'

# roles and permissions
gem 'pundit'

# Postgresql query analysis
gem 'pghero'

# templating
gem 'haml-rails'

# flash notices for actions
gem 'responders'

# icons
gem 'font-awesome-rails'

# listens for incoming sensor readings on mqtt
gem 'mqtt'

gem 'will_paginate'

# pretty charts
gem 'chartkick'

# pagination
gem 'kaminari'

# email
gem 'sendgrid-ruby'

gem 'active_median'

gem 'momentjs-rails'

# OAuth for API
gem 'doorkeeper', '4.2.6'

# Rest/http library
gem 'faraday'

gem 'rack-cors', require: 'rack/cors'

gem 'nokogiri', '>= 1.8.1'
gem 'rails-html-sanitizer', '>= 1.0.4'

# notify if there any error come from server
gem 'exception_notification'
gem 'slack-notifier'

# sidekiq for support background job
gem 'sidekiq'

# API documentation
gem 'apidoco'

group :production, :staging do
  # for heroku
  # gem 'newrelic_rpm'
  gem 'rails_12factor'
  gem 'raygun4ruby'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # code style
  gem 'haml_lint', '0.26.0', require: false
  gem 'rubocop', '0.49.1', require: false
  gem 'scss_lint', require: false

  # pulls in config from environment variables
  gem 'dotenv-rails'

  # test runner
  gem 'rspec-rails'

  # content generators
  gem 'factory_bot_rails'
  gem 'faker'

  # Code coverage analysis
  gem 'codeclimate-test-reporter', require: false
  gem 'coveralls', require: false

  gem 'capybara'
  gem 'capybara-screenshot'

  gem 'bullet'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'letter_opener'

  # Counts data base queries on the page
  gem 'sql_queries_count'

  # Add annotate to model so field of database more clear
  gem 'annotate'
end

group :test do
  gem 'pundit-matchers', '~> 1.3.0'
  gem 'rails-controller-testing'
  gem 'timecop'
  gem 'rspec-sidekiq'
end

group :development, :test do
  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-rake',    require: false
  gem 'capistrano-pumactl', require: false
  gem 'capistrano-faster-assets', require: false
end
