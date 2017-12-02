# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'reek/rake/task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end
Reek::Rake::Task.new do |t|
  t.fail_on_error = false
end
YARD::Rake::YardocTask.new

task default: :spec
task lint: %i[rubocop reek]
task fulltest: %i[spec lint]
