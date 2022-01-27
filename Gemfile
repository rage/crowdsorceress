# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', '~> 1.0.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 9.0.6', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails', '~> 2.2.1'
  gem 'factory_girl_rails', '~> 4.8.0'
  gem 'rspec-rails', '~> 3.5'
  gem 'rspec-mocks', '~> 3.4', '>= 3.4.1'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.0.2'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console'
end

group :test do
  gem 'simplecov', '~> 0.15.0', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '~> 1.2017.2', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'oauth2', '~> 1.2'

gem 'sidekiq', '~> 5.2.9'

gem 'rubyzip', '~> 1.2', '>= 1.2.1'

gem 'http-cookie', '~> 1.0', '>= 1.0.3'
gem 'mime-types', '~> 2.99.3'
gem 'netrc', '~> 0.11.0'
gem 'rest-client', '~> 1.8'

gem 'paper_trail', '~> 7.1.0'

gem 'bootstrap', '~> 4.0.0.beta'
gem 'jquery-rails', '~> 4.3.1'
gem 'turbolinks', '~> 5'

gem 'sass-rails', '~> 5.0'

gem 'kaminari', '~> 1.1', '>= 1.1.1'
