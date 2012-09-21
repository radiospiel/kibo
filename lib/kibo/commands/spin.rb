# --spin up/spin down remotes
module Kibo::Commands
  subcommand :spinup, "starts all remote instances" do
    opt :force, "Ignore missing targets.", :short => "f"
  end

  subcommand :spindown, "stops all remote instances"

  def spinup
    check_missing_remotes(Kibo.command_line.force? ? :warn : :error)
    spin Kibo.config.processes
  end

  def spindown
    spin({})
  end

  private
  
  def spin(processes)
    Kibo.config.remotes_by_process.each do |name, remotes|
      number_of_processes = processes[name] || 0
      
      remotes.each do |remote|
        if number_of_processes > 0
          configure_remote remote 
          heroku "ps:scale", "#{name}=1", "--app", remote
          number_of_processes -= 1
        else
          heroku "ps:scale", "#{name}=0", "--app", remote
        end
      end
      
      if number_of_processes > 0
        W "Missing #{name} remote(s)", number_of_processes
      end
    end
  end
end
