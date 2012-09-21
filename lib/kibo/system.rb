module Kibo::System
  extend self

  def heroku(*args)
    sys! "heroku", *args
  end

  def git(*args)
    sys! "git", *args
  end

  def sys(*args)
    cmd = build_command(*args)
    result = Kernel.send "`", "bash -c \"#{cmd}\""
    if command_succeeded?(cmd)
      result.chomp
    end
  end

  def sys!(*args)
    sys(*args) || exit(1)
  end

  def sh(*args)
    cmd = build_command(*args)
    system(cmd)
    command_succeeded?(cmd)
  end

  def sh!(*args)
    sh(*args) || exit(1)
  end

  private
  
  def build_command(*args)
    quiet = args.pop if args.last == :quiet
    args[0].sub!(/^kibo\b/, $0)
    cmd = args.map(&:to_s).join(" ") 
    W cmd unless quiet
    cmd
  end

  def command_succeeded?(cmd)
    return true if $?.exitstatus == 0
    
    UI.error("Command failed: #{cmd}")
    false
  end
end

module Kibo
  extend System
end

