module Kibo::Commands
  subcommand :create, "create missing targets" do
    opt :all, "Create all missing targets.", :short => "a"
  end

  def create
    verify_heroku_login

    if Kibo.command_line.all? 
      instances = missing_remotes
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
      E "You are currently logged in as #{whoami}; please log in ('heroku auth:login') as #{config.account}."
    end
  end
end
