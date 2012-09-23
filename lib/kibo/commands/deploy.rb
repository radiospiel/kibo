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

    ENV["ENVIRONMENT"] = Kibo.environment
     
    #
    # Run source commands
    with_commands :source do

      # create a deployment branch, if there is none yet.
      in_branch "kibo.#{Kibo.environment}" do
        git "merge", "master"

        with_commands :deployment do
          h.configured_remotes.each do |remote| 
            deploy_remote! remote
          end
        end
      end
    end
  rescue StandardError
    W $!
    raise
  end

  private

  def with_commands(sym, &block)
    commands_hash = Kibo.config.send(sym) || {}
    
    run = lambda { |key| 
      next unless commands = commands_hash[key]

      W "Running #{sym}.#{key} commands"
      [ *commands ].each do |command|
        Kibo::System.sh! command
      end
    }

    run.call("pre")

    yield

    run.call("success")
  ensure
    run.call("final")
  end
  
  #
  # checkout the branch +name+, create it if necessary.
  def in_branch(name, &block)
    previous_branch = current_branch

    if name != previous_branch
      git "branch", name unless branches.include?(name)
      git "checkout", name
    end
    
    yield
  rescue StandardError
    STDERR.puts $!
    raise
  ensure
    unless current_branch == previous_branch
      git "reset", "--hard"
      git "checkout", previous_branch
    end
  end

  def current_branch
    `git rev-parse --abbrev-ref HEAD`.chomp
  end
  
  def branches
    branches = `git branch`
    ("\n" + branches).split(/\n[\* ]+/).reject(&:empty?)
  end
    
  def deploy_remote!(remote)
    git "push", "--force", remote, "HEAD:master"
  end
end
