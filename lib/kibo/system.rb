module Kibo::System
  extend self

  def heroku(*args)
    sys! "heroku", *args
  end

  def git(*args)
    sys! "git", *args
  end

  def sys(*args)
    quiet = args.pop if args.last == :quiet

    cmd = build_command(quiet, *args)
    result = Kernel.send "`", "bash -c \"#{cmd}\""
    if command_succeeded?(quiet, cmd)
      result.chomp
    end
  end

  def sys!(*args)
    sys(*args) || exit(1)
  end

  private

  def build_command(quiet, *args)
    args[0].sub!(/^kibo\b/, $0)
    cmd = args.map(&:to_s).join(" ") 
    W cmd unless quiet
    cmd
  end

  def command_succeeded?(quiet, cmd)
    return true if $?.exitstatus == 0
    
    UI.error("Command failed: #{cmd}") unless quiet
    false
  end
end

module Kibo
  extend System
end

