#
# 

require_relative "../heroku"

module Kibo::Commands
  subcommand :setup, "Setup and configure application instances" do
    opt :force, "Reconfigure existing instances.", :short => "f"
  end
  
  subcommand :reconfigure, "Reconfigure application instances"

  def setup
    verify_heroku_login
    
    # create all apps on heroku or make sure that they
    # exist as remotes in the local git configuration.
    Kibo.config.instances.each do |instance|
      next unless create_instance(instance) || Kibo::CommandLine.force?

      # The following only when forced (--force) to do so 
      # or when a new instance has been created.

      provide_instance instance
      share_instance instance
      configure_instance instance
    end
  end
  
  def reconfigure
    # create all apps on heroku or make sure that they
    # exist as remotes in the local git configuration.
    Kibo.config.instances.each do |instance|
      provide_instance instance
      share_instance instance
      configure_instance instance
    end
  end
  
  def create_instance(instance)
    return false if sys("git remote | grep #{instance}", :quiet)

    heroku_url = "git@heroku.com:#{instance}.git"

    if Kibo::Heroku.apps.include?(instance)
      git :remote, :add, instance, heroku_url
    else
      heroku! "apps:create", instance, "--remote", instance
    end
    
    true
  end

  def list_heroku(what, instance)
    heroku!(what, "--app", instance, :quiet).
      split("\n").
      reject  { |line| line =~ /^=== / }.
      map     { |line| line.split(/\s+/).first }
  end
  
  def share_instance(instance)
    existing_sharings = list_heroku("sharing", instance)

    missing_sharings = Kibo.config.sharing - existing_sharings
    Kibo.config.sharing.each do |email|
      heroku! "sharing:add", email, "--app", instance
    end
  end
  
  def provide_instance(instance)
    partial_instance_name = instance.split("-").last # e.g. "web1"

    instance_addons = Kibo.config.addons[partial_instance_name] || []
    return if instance_addons.empty? 

    existing_instance_addons = list_heroku("addons", instance)
    W "[#{instance}] addons", *existing_instance_addons

    missing = instance_addons - existing_instance_addons
    missing.each do |addon|
      heroku! "addons:add", addon, "--app", instance
    end
  end

  def configure_instance(instance)
    heroku! "config:set", "INSTANCE=#{instance.instance_name}", "--app", instance
  end

  def verify_heroku_login
    whoami = Kibo::Heroku.whoami
    return if whoami == Kibo.config.heroku.account

    if !whoami
      E "Please log in ('heroku auth:login') as #{Kibo.config.heroku.account}."
    elsif whoami != Kibo.config.heroku.account
      E "You are currently logged in as #{whoami}; please log in ('heroku auth:login') as #{Kibo.config.heroku.account}."
    end
  end
end
