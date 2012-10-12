# --spin up/spin down remotes
module Kibo::Commands
  subcommand :per_instance, "run a command once on each heroku instances"
  subcommand :per_role, "run a command once on each heroku role"

  def per_instance
    if configured_instances.empty?
      E "No configured_instances in '#{Kibo.environment}' environment."
    end

    configured_instances.each do |instance|
      cmd = [ "heroku", *ARGV, "--app", instance ]
      W cmd.join(" ")
      system *cmd
    end
  end

  def per_role
    if configured_instances.empty?
      E "No configured_instances in '#{Kibo.environment}' environment."
    end

    configured_roles = configured_instances.group_by do |name|
      name.split("-").last.sub(/\d+$/, "")
    end
 
    instances = configured_roles.values.first
    
    instances.each do |instance|
      cmd = [ "heroku", *ARGV, "--app", instance ]
      W cmd.join(" ")
      system *cmd
    end
  end
end
