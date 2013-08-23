require "bundler/setup"
require "appraisal"

task :default do
  sh "rake appraisal:install && rake appraisal test"
end

require 'rspec/core/rake_task'
desc 'Run the unit tests'
RSpec::Core::RakeTask.new(:test)
