require "bundler/setup"
require "bundler/gem_tasks"

$:.unshift File.expand_path("../lib", __FILE__)

Dir[File.expand_path("../tasks/*.rake", __FILE__)].each do |task|
  load task
end

task :release => "doc:commit"
