# --spin up/spin down remotes
module Kibo::Commands
  subcommand :heroku, "run a command on all heroku instances"

  def heroku
    if configured_instances.empty?
      E "No configured_instances in '#{Kibo.environment}' environment."
    end

    configured_instances.each do |instance|
      cmd = [ "heroku", *ARGV, "--app", instance ]
      W cmd.join(" ")
      system *cmd
    end
  end
end
