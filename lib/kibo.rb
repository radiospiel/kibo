require "pp"
require "heroku"

module Kibo
end

require_relative "kibo/log"
require_relative "kibo/system"
require_relative "kibo/config"
require_relative "kibo/commandline"

module Kibo
  extend self

  def kibofile_example
    namespace = File.basename Dir.getwd 
    account = whoami || "user@domain.com"
    
    kibo = <<-EXAMPLE
# This is an example Kibofile. Use with kibo(1) to configure
# remote instances.
heroku:
  #
  # The heroku account to create application instances on heroku.
  account: #{account}
  #
  # The namespace setting influences the name of the heroku app instances:
  # Your instances will be called '#{namespace}-{environment}-{process}{number}',
  # e.g. '#{namespace}-production-worker0'.
  namespace: #{namespace}
defaults:
  web: 1
  worker: 1
production:
  web: 1
  worker: 2
EXAMPLE
  end

  def generate
    if File.exists?(CommandLine.kibofile)
      E "#{CommandLine.kibofile}: already existing."
      return
    end
    
    File.open(CommandLine.kibofile, "w") do |io|
      io.write kibofile_example
    end
    C "#{CommandLine.kibofile}: created."
  end

  def config
    @config ||= Config.new(CommandLine.kibofile)
  end

  def environment
    Kibo::CommandLine.environment
  end
  
  def expected_remotes
    config.processes.inject([]) do |ary, (name, count)|
      ary.concat 1.upto(count).map { |idx| "#{config.namespace}-#{environment}-#{name}#{idx}" }
    end
  end

  def configured_remotes
    config.remotes_by_process.values.flatten
  end

  def missing_remotes
    expected_remotes - configured_remotes
  end
  
  # -- configure a remote
  
  private
  
  def instance_for_remote(remote)
    remote[config.namespace.length + 1 .. -1]
  end
  
  public
  
  def configure_remote!(remote)
    heroku "config:set", 
      "RACK_ENV=#{environment}", 
      "RAILS_ENV=#{environment}", 
      "INSTANCE=#{instance_for_remote(remote)}", 
      "--app", remote
  end
  
  def configure_remote(remote)
    # the correct value for the INSTANCE configuration setting is the 
    # name of the of the remote without the namespace part; e.g. the 
    # INSTANCE for the remote named "bountyhill-staging-twirl2" is 
    # "staging-twirl2".
    instance = remote[config.namespace.length + 1 .. -1]
    current_instance = heroku "config:get", "INSTANCE", "--app", remote
    return if instance == current_instance
  end
  
  # --spin up/spin down remotes
  
  private
  
  def spin(processes)
    config.remotes_by_process.each do |name, remotes|
      number_of_processes = processes[name] || 0
      
      remotes.each do |remote|
        if number_of_processes > 0
          configure_remote remote 
          heroku "ps:scale", "#{name}=1", "--app", remote
          number_of_processes -= 1
        else
          heroku "ps:scale", "#{name}=0", "--app", remote
        end
      end
      
      if number_of_processes > 0
        W "Missing #{name} remote(s)", number_of_processes
      end
    end
  end
  
  public
  
  def spinup
    check_missing_remotes(CommandLine.force? ? :warn : :error)
    spin config.processes
  end

  def spindown
    spin({})
  end
  
  # reconfigure existing remotes
  public 

  # kibo [options] reconfigure                ... reconfigure all existing remotes
  def reconfigure
    check_missing_remotes :warn
    
    configured_remotes.each do |remote| 
      configure_remote! remote
    end
  end

  private
  
  def prepare_deployment
  end
  
  def deploy_remote!(remote)
    git "push", remote, "master"
  end
  
  public
  
  def deploy
    check_missing_remotes(CommandLine.force? ? :warn : :error)
    
    prepare_deployment
    configured_remotes.each do |remote| 
      deploy_remote! remote
    end
    
    W "Deployment succeeded."
  end
  
  private
  
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
  
  public
  
  def create
    verify_heroku_login
    
    if CommandLine.all? 
      instances = missing_remotes
      if instances.empty?
        W "Nothing to do."
        exit 0
      end
    else
      instances = CommandLine.args
      if instances.empty?
        W "Add the names of the remotes to create on the command line or use the --all parameter."
        exit 0
      end

      # only create instances that are actually missing.
      extra_instances = instances - missing_remotes
      unless extra_instances.empty?
        E <<-MSG
kibo cannot create these instances for you: #{extra_instances.map(&:inspect).join(", ")}, because I don't not know anything about these.
MSG
      end
    end
  
    confirm! <<-MSG
I am going to create these instances: #{instances.map(&:inspect).join(", ")}. Is this what you want? Note:
You are logged in at heroku as #{config.account}.
MSG

    instances.each do |instance|
      create_instance(instance)
    end
  end

  def confirm!(msg)
    puts msg
    puts "\n\nPress ^C to abort or return to continue."
    
    STDIN.read
  end
  
  private

  def whoami
    (Heroku::Auth.read_credentials || []).first
  end
  
  def verify_heroku_login
    whoami = self.whoami
    if !whoami
      E "Please log in ('heroku auth:login') as #{config.account}."
    elsif whoami != config.account
      E "You are currently logged in as #{whoami}; please log in ('heroku auth:login') as #{config.account}."
    end
  end
  
  def create_instance(remote)
    # TODO: Test whether these instances already exist, using `heroku apps`
    heroku "apps:create", remote, "--remote", remote
  end
  
  public
  
  def run
    self.send CommandLine.subcommand
  end
end
