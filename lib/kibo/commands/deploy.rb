module Kibo::Commands
  subcommand :deploy, "updates all remote instances"

  def deploy
    ENV["ENVIRONMENT"] = Kibo.environment
     
    #
    # Run source commands
    with_commands :source do
      with_stashed_changes do
        # create a deployment branch, if there is none yet.
        in_branch "kibo.#{Kibo.environment}" do
          git "merge", "master"

          with_commands :arena do
            Kibo.config.instances.each do |instance| 
              git "push", "--force", instance, "HEAD:master"
            end
          end
        end
      end
    end
  rescue StandardError
    W $!
    raise
  end

  private

  # Run the commands under "<key>.pre", 
  # then yield the block, 
  # then run the commands under "<key>.success", if the block was successful,
  # then run the commands under "<key>.final".
  def with_commands(sym, &block)
    commands_hash = Kibo.config.send(sym) || {}
    
    run = lambda { |key| 
      next unless commands = commands_hash[key]

      W "Running #{sym}.#{key} commands"
      [ *commands ].each do |command|
        Kibo::System.sys! command
      end
    }

    run.call("pre")

    yield

    run.call("success")
  ensure
    run.call("final") if run
  end
  
  def dirty?
    return false if git? "diff-index", "--quiet", "HEAD", :quiet

    true
  end
  
  def with_stashed_changes(&block)
    is_clean = git? "diff-index", "--quiet", "HEAD", :quiet
    git "stash" unless is_clean
    yield
  ensure
    git "stash", "pop" unless is_clean
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
end
