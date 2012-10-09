require 'rubygems'
require 'bundler/setup'

ENV["RACK_ENV"] ||= "test"

require 'ruby-debug'
require 'simplecov'
require 'test/unit'
require 'test/unit/ui/console/testrunner'   

class Test::Unit::UI::Console::TestRunner
  def guess_color_availability; true; end
end

require 'mocha'
require 'awesome_print'

SimpleCov.start do
  add_filter "test/*.rb"
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'kibo'

