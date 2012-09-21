module Kibo::Commands
  subcommand :deploy, "updates all remote instances" do
    opt :force, "Ignore outstanding changes.", :short => "f"
  end

  def deploy
    h.check_missing_remotes(Kibo.command_line.force? ? :warn : :error)
    
    prepare_deployment
    h.configured_remotes.each do |remote| 
      deploy_remote! remote
    end
    
    W "Deployment succeeded."
  end

  private
  
  def deploy_remote!(remote)
    git "push", remote, "master"
  end

  def prepare_deployment
  end
end
