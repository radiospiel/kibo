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

  # You instances will be called 'kiboex-staging-web0', 'kiboex-production-worker0', etc.
  namespace: kiboex

# What to do before and after deployment? These steps are run in the order 
# defined here, and in an checked out deployment repository.
deployment:
  pre:
    - git rm -rf public/assets || true
    - rake assets:rebuild
    - kibo compress --quiet public/assets
    - git add -f public/assets
    - git commit -m '[kibo] Updated assets'
  post:
    - heroku run rake db:migrate
defaults:
  web: 1
  worker: 1
production:
  web: 1
  worker: 2
EXAMPLE
  end
end

