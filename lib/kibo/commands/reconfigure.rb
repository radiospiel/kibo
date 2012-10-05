module Kibo::Commands
  subcommand :reconfigure, "reconfigure all existing targets"

  # kibo [options] reconfigure                ... reconfigure all existing remotes
  def reconfigure
    h.check_missing_remotes :warn
    
    h.configured_remotes.each do |remote| 
      h.configure_remote! remote
    end
  end
end
