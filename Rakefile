require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require "rubocop/rake_task"

Dir.glob('lib/tasks/*.rake').each { |r| import r }

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: [:rubocop, :spec]
