module Kibo::Helpers
end

require_relative "./helpers/heroku"
require_relative "./helpers/info"

module Kibo::Helpers
  extend self

  extend Heroku

  def sys
    Kibo::System
  end
  
  def check_missing_remotes(mode = :warn)
    return if missing_remotes.empty?

    if mode == :warn
      W  "Ignoring missing remote(s)", *missing_remotes
      return
    end

    E <<-MSG
Missing remote(s): #{missing_remotes.map(&:inspect).join(", ")}. Run

  kibo --environment #{environment} create --all              # ... to create all missing remotes.
  kibo --environment #{environment} spinup --force            # ... to ignore missing remotes.

    MSG
  end

  # -- configure remotes ----------------------------------------------
  
  def configure_remote!(remote)
    sys.heroku "config:set", 
      "RACK_ENV=#{environment}", 
      "RAILS_ENV=#{environment}", 
      "INSTANCE=#{instance_for_remote(remote)}", 
      "--app", remote
  end
  
  def instance_for_remote(remote)
    remote[config.namespace.length + 1 .. -1]
  end
  
  def configure_remote(remote)
    # the correct value for the INSTANCE configuration setting is the 
    # name of the of the remote without the namespace part; e.g. the 
    # INSTANCE for the remote named "bountyhill-staging-twirl2" is 
    # "staging-twirl2".
    instance = remote[Kibo.config.namespace.length + 1 .. -1]
    current_instance = sys.heroku "config:get", "INSTANCE", "--app", remote
    return if instance == current_instance
  end

  # -- which remotes are defined, present and configured --------------
  
  def expected_remotes
    namespace, environment = Kibo.config.namespace, Kibo.environment
    
    Kibo.config.processes.map do |name, count|
      1.upto(count).map { |idx| "#{namespace}-#{environment}-#{name}#{idx}" }
    end.flatten.sort
  end

  def configured_remotes
    Kibo.config.remotes_by_process.values.flatten
  end

  def missing_remotes
    expected_remotes - configured_remotes
  end
end
