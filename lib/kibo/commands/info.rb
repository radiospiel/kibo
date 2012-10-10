require_relative "../helpers/info"

module Kibo::Commands
  subcommand :info, "show information about the current settings"

  def info
    Kibo::Helpers::Info.print do |info|
      info.head "general"
      info.line "environment", Kibo.environment
      info.line "namespace", Kibo.namespace
      
      info.head "heroku"
      info.line "current account", Kibo::Heroku.whoami
      info.line "expected account", Kibo.config.heroku.account

      info.head "processes"      
      info.line "mode", Kibo.config.heroku.mode
      Kibo.config.processes.each do |key, value|
        info.line key, value
      end

      # info.head "remotes"
      # 
      # info.line "expected", Kibo.expected_remotes
      # info.line "configured", Kibo.configured_remotes
      # info.line "missing", Kibo.missing_remotes

      info.head "instances"
      
      info.line "expected", Kibo.config.instances
      info.line "configured", configured_instances
    end
  end

  def configured_instances
    sys("git remote", :quiet).split("\n").select { |line|
      line =~ /^#{Kibo.namespace}-#{Kibo.environment}/
    }
  end
end
