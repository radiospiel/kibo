module Kibo::System
  extend self
  
  def heroku(*args)
    W "heroku " + args.join(" ")
    return
    sys! "heroku", *args
  end

  def git(*args)
    sys! "git", *args
  end

  def sys(*args)
    cmd = args.map(&:to_s).join(" ")
    stdout = Kernel.send "`", "bash -c \"#{cmd}\""
    
    stdout.chomp if $?.exitstatus == 0
  end

  def sys!(*args)
    sys(*args) || die("Command failed", args.join(" "))
  end
end

module Kibo
  extend System
end

