# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.5.7'

gem 'actionview', '>= 5.0.7.2'
gem 'bootstrap-sass', '3.3.6'
gem 'coffee-rails', '~> 4.2'
gem 'dotenv-rails'
gem 'execjs'
gem 'fullcalendar-rails'
gem 'google-api-client', '~> 0.11', require: 'google/apis/calendar_v3'
gem 'haml'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'momentjs-rails'
gem 'omniauth-google-oauth2', '0.7.0'
gem 'paper_trail'
gem 'paranoia', '~> 2.2'
gem 'pg'
gem 'puma', '~> 3.12'
gem 'rails', '~> 5.0.2'
gem 'sass-rails', '~> 5.0'
gem 'slacked'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'
gem 'whenever'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'factory_girl_rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'shoulda-matchers'
  gem 'simplecov'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data'
