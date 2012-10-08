#
# 

require_relative "../heroku"

module Kibo::Commands
  subcommand :setup, "Setup and configure application instances" do
    opt :force, "Reconfigure existing instances, too.", :short => "f"
  end

  def setup
    verify_heroku_login
    
    # create all apps on heroku or make sure that they
    # exist as remotes in the local git configuration.
    instances.each do |instance|
      next unless create_instance(instance) || Kibo::CommandLine.force?

      # The following only when forced (--force) to do so or when
      # a new instance has been created.
      collaborate_instance instance
      provide_instance instance
      configure_instance instance
    end
  end
  
  def create_instance(instance)
    return false if sys("git remote | grep #{instance}", :quiet)

    heroku_url = "git@heroku.com:#{instance}.git"

    if Kibo::Heroku.apps.include?(instance)
      git :remote, :add, instance, heroku_url
    else
      heroku "apps:create", instance, "--remote", instance
    end
    
    true
  end
  
  def collaborate_instance(instance)
    Kibo.config.collaborators.each do |email|
      heroku "sharing:add", email, "--app", instance
    end
  end
  
  def provide_instance(instance)
    instance.addons.each do |addon|
      heroku "addons:add", addon
    end
  end

  def configure_instance(instance)
    heroku "config:set", "INSTANCE=#{instance}"
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
