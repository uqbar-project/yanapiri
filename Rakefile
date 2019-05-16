require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "bump/tasks"

RSpec::Core::RakeTask.new(:spec)
Bump.tag_by_default = true

task :default => :spec
