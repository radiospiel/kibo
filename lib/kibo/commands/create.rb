module Kibo::Commands
  subcommand :remotes, "create missing remotes" do
    opt :all, "Create all missing remotes.", :short => "a"
  end

  subcommand :create, "create missing apps"
  
  subcommand :collaborate, "add collaborations"

  def create
    verify_heroku_login

    apps = heroku("apps").split("\n").reject { |line| line =~ /===/ }
    missing_apps = h.expected_remotes - apps
    
    confirm! <<-MSG
I am going to create these instances: #{missing_apps.map(&:inspect).join(", ")} for you [#{Kibo.config.account}].
MSG

    missing_apps.each do |instance|
      create_instance(instance)
      Kibo.config.collaborations.each do |email|
        heroku "sharing:add", email 
      end
    end
  end

  def collaborate
    verify_heroku_login
    
    h.expected_remotes.each do |instance|
      Kibo.config.collaborations.each do |email|
        heroku "sharing:add", email, "--app", instance
      end
    end
  end
  
  def remotes
    if Kibo.command_line.all? 
      instances = h.missing_remotes
      if instances.empty?
        W "Nothing to do."
        exit 0
      end
    else
      instances = Kibo.command_line.args
      if instances.empty?
        W "Add the names of the remotes to create on the command line or use the --all parameter."
        exit 0
      end

      # only create instances that are actually missing.
      extra_instances = instances - h.missing_remotes
      unless extra_instances.empty?
        E <<-MSG
kibo cannot create these instances for you: #{extra_instances.map(&:inspect).join(", ")}, because I don't not know anything about these.
MSG
      end
    end

    h.missing_remotes.each do |remote|
      git "remote", "add", remote, "git@heroku.com:#{remote}.git"
    end
  end
  
  private
  
  def create_instance(remote)
    # TODO: Test whether these instances already exist, using `heroku apps`
    heroku "apps:create", remote, "--remote", remote
  end

  def verify_heroku_login
    whoami = h.whoami
    if !whoami
      E "Please log in ('heroku auth:login') as #{config.account}."
    elsif whoami != Kibo.config.account
      E "You are currently logged in as #{whoami}; please log in ('heroku auth:login') as #{Kibo.config.account}."
    end
  end
end
