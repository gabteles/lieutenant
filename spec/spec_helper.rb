# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'
require 'coveralls'
Coveralls.wear!
require 'simplecov'

Bundler.require(:test)

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])

SimpleCov.start do
  add_filter '/spec/'
end

require 'lieutenant'

Dir['spec/helpers/**/*.rb'].each { |file| require(File.expand_path(file)) }

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
