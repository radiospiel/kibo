# --spin up/spin down remotes
module Kibo::Commands
  subcommand :spinup, "starts all remote instances"
  subcommand :spindown, "stops all remote instances"

  def spinup
    spin :up
  end

  def spindown
    spin :down
  end

  private
  
  def spin(mode)
    Kibo.config.instances.each do |instance|
      count = mode == :up ? instance.count : 0
      heroku "ps:scale", "#{instance.role}=#{count}", "--app", instance
    end
  end
end
