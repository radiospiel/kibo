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
    cmd = args.map(&:to_s).join(" ") 
    W cmd unless quiet
    
    # A command is run because it either is "quiet", i.e. is non-obstrusive anyway,
    # or we are not in a dry. Dry run mode could go with some improvements, though.
    if quiet || !Kibo::CommandLine.dry?
      stdout = Kernel.send "`", "bash -c \"#{cmd}\""
      stdout.chomp if $?.exitstatus == 0
    else
      ""
    end
  end

  def sys!(*args)
    sys(*args) || E("Command failed: " + args.join(" "))
  end
end

module Kibo
  extend System
end

