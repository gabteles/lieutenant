# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :test do
  gem 'byebug'
end

group :development, :test do
  gem 'bundler'
  gem 'coveralls'
  gem 'pry'
  gem 'rake'
  gem 'reek'
  gem 'rspec'
  gem 'rubocop'
  gem 'simplecov'
  gem 'yard'
end
