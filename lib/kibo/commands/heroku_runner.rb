# --spin up/spin down remotes
module Kibo::Commands
  subcommand :heroku, "run a command on all heroku instances"

  def heroku
    #W "ARGV", ARGV
    
    Kibo.config.instances.each do |instance|
      cmd = [ "heroku", *ARGV, "--app", instance ]
      
      W cmd.join(" ")
      system *cmd
    end
  end
end
