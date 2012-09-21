module Kibo::Commands
  subcommand :deploy, "updates all remote instances" do
    opt :force, "Ignore outstanding changes.", :short => "f"
  end

  def deploy
    if Kibo.command_line.force?
      h.check_missing_remotes(:warn)
    else
      h.check_missing_remotes(:error)
    end

    run_commands Kibo.config.deployment["first"]
    W "first commands done"

    #
    # create a deployment branch, if there is none yet.
    checkout_branch Kibo.environment
  
    git "merge", "master"
    run_commands Kibo.config.deployment["pre"]
    W "pre commands done"
    
    h.configured_remotes.each do |remote| 
      deploy_remote! remote
    end
    
    W "Deployment succeeded."
    run_commands Kibo.config.deployment["post"]
  rescue StandardError
    W $!
    raise
  ensure
    unless current_branch == "master"
      git "reset", "--hard"
      git "checkout", "master"
    end
  end

  private
  
  def checkout_branch(name)
    unless branches.include?(name)
      Kibo::System.git "branch", name
    end
    
    git "checkout", name
  end
  
  def current_branch
    `git branch`.split(/\n/).detect do |line|
      line =~ /^* /
    end.sub(/^\* /, "")
  end
  
  def branches
    branches = `git branch`
    ("\n" + branches).split(/\n[\* ]+/).reject(&:empty?)
  end
    
  def deploy_remote!(remote)
    git "push", remote, "HEAD:master"
  end

  def run_commands(commands)
    return unless commands
    commands = [ commands ] if commands.is_a?(String)

    commands.each do |command|
      Kibo::System.sh! command
    end
  end
end
