module Kibo
end

require_relative "kibo/version"
require_relative "kibo/log"
require_relative "kibo/system"
require_relative "kibo/config"
require_relative "kibo/commands"
require_relative "kibo/commandline"

module Kibo
  extend self
  
  def config
    @config ||= Config.new(kibofile)
  end

  def environment
    CommandLine.environment
  end
  
  def run
    Commands.send CommandLine.subcommand
  end

  def command_line
    CommandLine
  end

  def kibofile
    command_line.kibofile
  end
end
