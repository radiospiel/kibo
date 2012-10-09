module Kibo
end

require_relative "kibo/ext/ruby_ext.rb"
require_relative "kibo/version"
require_relative "kibo/log"
require_relative "kibo/system"
require_relative "kibo/config"
require_relative "kibo/commands"
require_relative "kibo/commandline"

module Kibo
  extend self
  
  def config
    @config ||= Config.new(CommandLine.config, CommandLine.environment)
  end

  def environment
    Kibo.config.environment
  end
  
  def namespace
    Kibo.config.heroku.namespace
  end
  
  def run
    Commands.send CommandLine.subcommand
  rescue RuntimeError
    UI.error $!.to_s 
    exit 1
  end
  
  def binary
    File.join(File.dirname(__FILE__), "..", "bin", "kibo")
  end
end
