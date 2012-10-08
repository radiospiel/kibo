module Kibo::Commands
  subcommand :logs, "Show log files for current instances"
  def logs
    require "foreman/engine/cli"

    cli = Foreman::Engine::CLI.new
    
    Kibo.config.instances.map do |remote|
      cli.register remote.split("-", 3).last, "#{Kibo.binary} log #{remote}"
    end
    
    cli.start
  end

  subcommand :log, "Show log file for a single instance"
  def log
    require "heroku"

    instance = Kibo::CommandLine.args.first 

    $stdout.sync = true
    
    heroku = Heroku::Auth.client
    heroku.read_logs(instance, [ "tail=1" ]) do |chunk|
      chunk.split("\n").each do |line|
        $stdout.puts line.split(": ", 2)[1]
      end
    end
  end
end
