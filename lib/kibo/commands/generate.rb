module Kibo::Commands
  subcommand :generate, "generate an example Kibofile"

  def generate
    if File.exists?(Kibo.kibofile)
      E "#{Kibo.kibofile}: already existing."
      return
    end
    
    File.open(Kibo.kibofile, "w") do |io|
      io.write kibofile_example
    end
    S "#{Kibo.kibofile}: created."
  end

  private
  
  def kibofile_example
    namespace = File.basename Dir.getwd 
    account = h.whoami || "user@domain.com"

    kibo = <<-EXAMPLE
# This is an example Kibofile. Use with kibo(1) to configure
# remote instances.
heroku:
  #
  # The heroku account to create application instances on heroku.
  account: #{account}
  #
  # The namespace setting influences the name of the heroku app instances:
  # Your instances will be called '#{namespace}-{environment}-{process}{number}',
  # e.g. '#{namespace}-production-worker0'.
  namespace: #{namespace}
defaults:
  web: 1
  worker: 1
production:
  web: 1
  worker: 2
EXAMPLE
  end
end
