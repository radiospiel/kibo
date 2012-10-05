module Kibo::Commands
  subcommand :info, "show information about the current settings"

  def info
    Kibo::Helpers::Info.print do |info|
      info.head "general"
      info.line "environment", Kibo.environment

      info.head "heroku"
      info.line "current account", h.whoami
      info.line "expected account", Kibo.config.account

      info.head "processes"      
      Kibo.config.processes.each do |key, value|
        info.line key, value
      end

      info.head "remotes"
      info.line "remotes", h.expected_remotes
      info.line "configured", h.configured_remotes
      info.line "missing", h.missing_remotes
    end
  end

  subcommand :logs, "Show log files for current instances"
  def logs
    h.configured_remotes.each do |remote|
      fork do
        cmd = "heroku logs --tail --app #{remote} | sed s/^/\\\\[#{remote}\\\\]\\ /"
        W cmd
        exec(cmd)
      end
    end
    
    Process.waitall
  end
end
