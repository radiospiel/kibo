module Kibo::Commands
  subcommand :reconfigure, "reconfigure all existing targets"

  # kibo [options] reconfigure                ... reconfigure all existing remotes
  def reconfigure
    check_missing_remotes :warn
    
    configured_remotes.each do |remote| 
      configure_remote! remote
    end
  end
end
